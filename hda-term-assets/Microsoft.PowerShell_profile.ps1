# ============================
# PowerShell Profile Configuration
# ============================

# Variable de control para mostrar tiempos de carga
$ShowLoadingTimes = $false  # Cambiar a $true para ver métricas

# ============================
# Configuración UTF-8 para PowerShell
# ============================
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::InputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Establecer página de códigos UTF-8 (opcional pero recomendado)
if (Get-Command chcp -ErrorAction SilentlyContinue) {
    chcp 65001 > $null
}

# ============================
# Ajuste para mejorar el tiempo de carga
# ============================

# Iniciando medición de tiempo
$profileStartTime = Get-Date
$lastCheckpoint = $profileStartTime

# Función para mostrar el tiempo de carga
function Show-ProfileLoadTime {
    $loadTime = (Get-Date) - $profileStartTime
    $milliseconds = [math]::Round($loadTime.TotalMilliseconds)
    
    # Solo mostrar si excede 1 segundo (1500ms)
    if ($milliseconds -gt 1500) {
        Write-Host "Perfil de PowerShell cargado en $milliseconds ms." -ForegroundColor Yellow
    }
}

# Función para medir el tiempo de carga por bloques
function Measure-Block {
    param([string]$BlockName)
    $current = Get-Date
    $blockTime = ($current - $lastCheckpoint).TotalMilliseconds
    $totalTime = ($current - $profileStartTime).TotalMilliseconds
	if ($milliseconds -gt 3000 -and -not $ShowLoadingTimes) {
        Write-Host "Arranque lento detectado. Métricas para próximo inicio:" -ForegroundColor Yellow
        Write-Host "Cambiar `$ShowLoadingTimes = `$true en el perfil" -ForegroundColor Cyan
    }
    if ($ShowLoadingTimes) {
        Write-Host "${BlockName}: $([math]::Round($blockTime))ms (total: $([math]::Round($totalTime))ms)" -ForegroundColor DarkGray
    }
    $script:lastCheckpoint = $current
}


# Registramos para ejecutar al final del perfil
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action { 
    # Cualquier limpieza necesaria al cerrar PowerShell
} -SupportEvent
function Test-ModuleAvailability {
    param (
        [string]$ModuleName
    )
    
    if (-not (Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "⚠️ Módulo '$ModuleName' no encontrado. Algunas funciones pueden no estar disponibles." -ForegroundColor Yellow
        return $false
    }
    return $true
}

# Verificación inicial silenciosa de módulos críticos
$missingCriticalModules = $false
$criticalModules = @("PSReadLine")
foreach ($module in $criticalModules) {
    if (-not (Test-ModuleAvailability $module)) {
        $missingCriticalModules = $true
    }
}

if ($missingCriticalModules) {
    Write-Host "⚠️ Faltan módulos críticos. Ejecute el siguiente comando como administrador:" -ForegroundColor Red
    Write-Host "Install-Module -Name PSReadLine -Force -SkipPublisherCheck" -ForegroundColor Cyan
}

# Verificar si se ejecutó la verificación de módulos hoy
$verificationCachePath = "~/.ps_modules_verified"
$today = Get-Date -Format "yyyy-MM-dd"
$lastVerification = if (Test-Path $verificationCachePath) { Get-Content $verificationCachePath } else { "never" }

if ($lastVerification -ne $today) {
    # Verificar módulos recomendados cada día
    $modules = @(
        "Terminal-Icons",
        "posh-git", 
        "oh-my-posh",
        "PSFzf",
        "z",
        "syntax-highlighting",
        "PSWindowsUpdate"
    )
    
    $missingModules = @()
    foreach ($module in $modules) {
        if (-not (Get-Module -ListAvailable -Name $module)) {
            $missingModules += $module
        }
    }
    
    if ($missingModules.Count -gt 0) {
        Write-Host "`n📦 Módulos recomendados no instalados:" -ForegroundColor Yellow
        $installCommands = $missingModules | ForEach-Object { "Install-Module -Name $_ -Scope CurrentUser" }
        $installCommands | ForEach-Object { Write-Host "  $_" -ForegroundColor Cyan }
        Write-Host "Estos módulos mejorarán su experiencia con PowerShell." -ForegroundColor Yellow
    }
    
    # Guardar la fecha de verificación
    $today | Out-File -FilePath $verificationCachePath -Force
}
Measure-Block "Module Verification"

# ----------------------------
# Inicialización de Oh-My-Posh
# ----------------------------
# Verificar si oh-my-posh está instalado
if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    # Buscar el tema en múltiples ubicaciones posibles
    $possibleThemePaths = @(
        "~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json",
        "$env:LOCALAPPDATA/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json",
        "$env:POSH_THEMES_PATH/powerlevel10k_rainbow.omp.json",
        "$HOME/.poshthemes/powerlevel10k_rainbow.omp.json"
    )
    
    $themeFound = $false
    foreach ($themePath in $possibleThemePaths) {
        if (Test-Path $themePath) {
            & oh-my-posh init pwsh --config $themePath | Invoke-Expression
            $themeFound = $true
            break
        }
    }
    
    if (-not $themeFound) {
        # Si no se encuentra el tema específico, intentamos usar cualquier tema powerlevel10k
        $p10kThemes = Get-ChildItem "$env:LOCALAPPDATA/Programs/oh-my-posh/themes/" -Filter "*powerlevel10k*.omp.json" -ErrorAction SilentlyContinue
        if ($p10kThemes.Count -gt 0) {
            & oh-my-posh init pwsh --config $p10kThemes[0].FullName | Invoke-Expression
        } else {
            # Como último recurso, usar un tema predeterminado
            Write-Host "Tema powerlevel10k no encontrado. Usando tema predeterminado." -ForegroundColor Yellow
            & oh-my-posh init pwsh | Invoke-Expression
        }
    }
} else {
    Write-Host "Oh-My-Posh no está instalado. El prompt será estándar." -ForegroundColor Yellow
    Write-Host "Para instalar: winget install JanDeDobbeleer.OhMyPosh" -ForegroundColor Cyan
}
Measure-Block "Oh-my-posh"

# ----------------------------
# Información del sistema al iniciar la terminal
# ----------------------------
# Verificar si neofetch está instalado
if (Get-Command neofetch -ErrorAction SilentlyContinue) {
    # Ejecutar neofetch solo si el terminal tiene un ancho suficiente
    $width = $Host.UI.RawUI.WindowSize.Width
    if ($width -gt 80) {
        neofetch
    } else {
        Write-Host "Terminal demasiado estrecha para neofetch. Ancho actual: $width columnas." -ForegroundColor Yellow
    }
} else {
    Write-Host "Neofetch no está instalado. No se mostrará información del sistema." -ForegroundColor Yellow
}
Measure-Block "Neofetch"

# ----------------------------
# Configuración de EZA
# ----------------------------
Set-Variable EZA_ICONS_AUTO=auto^1

# ============================
# Funciones de utilidad general
# ============================

# ----------------------------
# Verifica si Virtual Terminal Processing está habilitado
# ----------------------------
function IsVirtualTerminalProcessingEnabled {
    $MethodDefinitions = @'
[DllImport("kernel32.dll", SetLastError = true)]
public static extern IntPtr GetStdHandle(int nStdHandle);
[DllImport("kernel32.dll", SetLastError = true)]
public static extern bool GetConsoleMode(IntPtr hConsoleHandle, out uint lpMode);
'@
    $Kernel32 = Add-Type -MemberDefinition $MethodDefinitions -Name 'Kernel32' -Namespace 'Win32' -PassThru
    $hConsoleHandle = $Kernel32::GetStdHandle(-11) # STD_OUTPUT_HANDLE
    $mode = 0
    $Kernel32::GetConsoleMode($hConsoleHandle, [ref]$mode) >$null
    return $mode -band 0x0004 # ENABLE_VIRTUAL_TERMINAL_PROCESSING
}

# ----------------------------
# Verifica si se puede usar la predicción
# ----------------------------
function CanUsePredictionSource {
    return (! [System.Console]::IsOutputRedirected) -and (IsVirtualTerminalProcessingEnabled)
}
Measure-Block "Check VTerm & prediction"

# ============================
# Carga de módulos y configuración
# ============================
if (CanUsePredictionSource) {
    # MÓDULOS CRÍTICOS (carga síncrona)
    Import-Module PSReadLine
    #Import-Module posh-git
    
    # MÓDULOS COMPLEMENTARIOS (carga asíncrona)
    $job = Start-Job -ScriptBlock {
        Import-Module posh-git, Terminal-Icons, PSWindowsUpdate, wt-shell-integration, syntax-highlighting -ErrorAction SilentlyContinue
    }
    
    # Carga e integración de PSFzf si está disponible
    $PSFzfModule = Get-Module -ListAvailable -Name PSFzf
    if ($PSFzfModule) {
        Import-Module PSFzf
        
        # Teclas para PSFzf (búsqueda interactiva en historial)
        Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
        
        # Habilitar la integración con Git si está disponible
        if (Get-Command git -ErrorAction SilentlyContinue) {
            Set-PsFzfOption -EnableGitIntegration $true
        }
        
        # Alias para funciones de PSFzf
        Set-Alias -Name fcd -Value Invoke-FuzzySetLocation
        Set-Alias -Name fe -Value Invoke-FuzzyEdit
        Set-Alias -Name fh -Value Invoke-FuzzyHistory
        Set-Alias -Name fkill -Value Invoke-FuzzyKillProcess
        Set-Alias -Name fpgrep -Value Invoke-FuzzyPsGrep
    } else {
        Write-Host "Para búsqueda difusa interactiva en terminal, considera instalar PSFzf:" -ForegroundColor DarkYellow
        Write-Host "Install-Module -Name PSFzf -Scope CurrentUser" -ForegroundColor DarkYellow
        Write-Host "Provee búsqueda interactiva en historial y navegación avanzada" -ForegroundColor DarkYellow
    }
    
    # Configuración de PSReadLine
    Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource History -HistoryNoDuplicates -EditMode Windows
    Set-PSReadLineOption -Colors @{
        "Command"        = "`e[38;5;82m"   # Verde
        "Parameter"      = "`e[38;5;220m"  # Amarillo
        "String"         = "`e[38;5;214m"  # Naranja
        "Operator"       = "`e[38;5;81m"   # Azul
    }
    
    # Historia mejorada - Similar a ZSH
    Set-PSReadLineOption -MaximumHistoryCount 3000
    Set-PSReadLineOption -HistorySearchCursorMovesToEnd
    
    # Atajos de teclado
    Set-PSReadlineKeyHandler -Key Tab -Function Complete
    # Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory  # PSFzf maneja Ctrl+r
    Set-PSReadlineKeyHandler -Key Ctrl+l -Function ClearScreen
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -BellStyle None
}
Measure-Block "Module Loading"

# ----------------------------
# Configuración de zoxide (navegación inteligente de directorios)
# ----------------------------

if (Get-Command zoxide -ErrorAction SilentlyContinue) {
    # Inicializar zoxide con cd como comando principal
    Invoke-Expression (& { (zoxide init --cmd cd powershell | Out-String) })
    
    # Función personalizada para búsqueda interactiva mejorada
    # Usamos 'cdz' en lugar de 'cdi' para evitar conflicto con zoxide
	function cdz {
		if (Get-Command fzf -ErrorAction SilentlyContinue) {
			# Obtener la línea seleccionada de fzf
			$selectedLine = zoxide query --list --score | fzf --height 40% --layout reverse --info inline --border --preview 'eza --color=always --icons {1..} 2>/dev/null || dir "{1..}" 2>/dev/null' --preview-window right:50%
			
			if ($selectedLine) {
				# Parsear la línea: formato es "score path"
				$parts = $selectedLine.Trim() -split '\s+', 2
				if ($parts.Count -ge 2) {
					$result = $parts[1]  # La ruta es el segundo elemento
					Set-Location $result
				} else {
					Write-Host "Error parseando la selección: $selectedLine" -ForegroundColor Red
				}
			}
		} else {
			# Fallback sin fzf funciona correctamente
			Write-Host "Directorios más frecuentes:" -ForegroundColor Cyan
			$directories = zoxide query --list --score | ForEach-Object { 
				$parts = $_ -split '\s+', 2
				[PSCustomObject]@{
					Score = [math]::Round([double]$parts[0], 1)
					Path = if ($parts.Count -ge 2) { $parts[1] } else { $_ }
				}
			} | Sort-Object Score -Descending | Select-Object -First 15
			
			$directories | Format-Table -AutoSize
			Write-Host "Usa 'cd <patrón>' para navegar rápidamente" -ForegroundColor Yellow
		}
	}
    
    # Alias adicionales para compatibilidad (los originales de zoxide quedan intactos)
    Set-Alias -Name z -Value __zoxide_z -ErrorAction SilentlyContinue
    # cdi y zi quedan como zoxide los definió originalmente
    
} else {
    Write-Host "⚠️ zoxide no está instalado. Funcionalidad de navegación inteligente no disponible." -ForegroundColor Yellow
    Write-Host "Para instalar: winget install ajeetdsouza.zoxide" -ForegroundColor Cyan
    Write-Host "Documentación: https://github.com/ajeetdsouza/zoxide" -ForegroundColor Cyan
    
    # Fallback básico - implementar funciones cd mejoradas simples
    function z {
        param([string]$Path)
        if ([string]::IsNullOrWhiteSpace($Path)) {
            Get-Location
        } else {
            Set-Location $Path
        }
    }
}
Measure-Block "Zoxide Configuration"


# ============================
# Utilidades avanzadas 
# ============================

# ============================
# Alias Finder para PowerShell
# Basado en el plugin alias-finder de Oh My Zsh
# ============================

## ----------------------------
# Función: CountActualPipes
# ----------------------------
function CountActualPipes {
    param([string]$command)
    
    try {
        $ast = [System.Management.Automation.Language.Parser]::ParseInput($command, [ref]$null, [ref]$null)
        $pipelineAsts = $ast.FindAll({ 
            param($node) 
            $node -is [System.Management.Automation.Language.PipelineAst] 
        }, $true)
        
        if ($pipelineAsts.Count -gt 0) {
            return ($pipelineAsts[0].PipelineElements.Count - 1)
        }
        return 0
    }
    catch {
        return 0
    }
}

# ----------------------------
# Función: ShouldShowAliasSuggestion
# ----------------------------
function ShouldShowAliasSuggestion {
    param([string]$originalCommand, [PSCustomObject]$alias)
    
    $firstCommand = ($originalCommand -split '\|')[0].Trim()
    
    # Criterios selectivos
    if ($firstCommand.Length -lt 8) { return $false }
    
    $pipeCount = CountActualPipes $originalCommand
    $argumentCount = ($originalCommand -split '\s+').Count
    if ($pipeCount -gt 1 -or $argumentCount -gt 10) { return $false }
    
    $absoluteSaving = $firstCommand.Length - $alias.Name.Length
    if ($absoluteSaving -lt 4) { return $false }
    
    return $true
}

# ----------------------------
# Función: Find-Alias
# ----------------------------
function Find-Alias {
    param (
        [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
        [string[]]$Command,
        [switch]$Exact,
        [switch]$Longer,
        [switch]$Cheaper,
        [switch]$Quiet,
        [switch]$Force
    )
    
    $fullCommand = ($Command -join ' ').Trim()
    if ([string]::IsNullOrWhiteSpace($fullCommand)) { return @() }
    
    $foundAliases = @()
    $currentCmd = $fullCommand
    
    while (-not [string]::IsNullOrWhiteSpace($currentCmd)) {
        # Buscar alias que coincidan con el comando actual
        $matchingAliases = Get-Alias | Where-Object {
            if ($Exact) {
                $_.Definition -eq $currentCmd
            } elseif ($Longer) {
                $_.Definition -like "*$currentCmd*"
            } else {
                $_.Definition -eq $currentCmd -or 
                ($currentCmd.StartsWith($_.Definition) -and 
                 $currentCmd.Length -gt $_.Definition.Length -and
                 $currentCmd[$_.Definition.Length] -match '\s')
            }
        } | ForEach-Object {
            [PSCustomObject]@{
                Name = $_.Name
                Definition = $_.Definition
            }
        }
        
        if ($Cheaper) {
            $matchingAliases = $matchingAliases | Where-Object {
                $_.Name.Length -lt $fullCommand.Length
            }
        }
        
        foreach ($alias in $matchingAliases) {
            if ($foundAliases.Name -notcontains $alias.Name) {
                $foundAliases += $alias
            }
        }
        
        if ($Exact -or $Longer) { break }
        
        $words = $currentCmd.Trim() -split '\s+'
        if ($words.Count -le 1) { break }
        $currentCmd = ($words[0..($words.Count-2)] -join ' ').Trim()
    }
    
    # Aplicar criterios selectivos
    if (-not $Force) {
        $foundAliases = $foundAliases | Where-Object { ShouldShowAliasSuggestion $fullCommand $_ }
    }
    
    # Mostrar resultados
    if (-not $Quiet -and $foundAliases.Count -gt 0) {
        $foundAliases | ForEach-Object { 
            Write-Host "$($_.Name) -> $($_.Definition)" -ForegroundColor Green
        }
    }
    
    return $foundAliases
}

# ----------------------------
# Función: Test-CommandAlias 
# ----------------------------
function Test-CommandAlias {
    param([Parameter(Mandatory=$true)][string]$Command)
    
    try {
        $cleanCommand = $Command.Trim() -replace '\s+', ' '
        if ([string]::IsNullOrWhiteSpace($cleanCommand)) { return }
        
        $firstToken = ($cleanCommand -split '\s+')[0]
        
        # Contar pipes reales (no dentro de strings)
		$pipeCount = CountActualPipes $cleanCommand
        
        # Criterios: comando largo, máximo 1 pipes, no es alias
        if ($firstToken.Length -ge 8 -and 
            $pipeCount -le 1 -and 
            -not (Get-Alias -Name $firstToken -ErrorAction SilentlyContinue)) {
            
            $aliasMatches = Get-Alias | Where-Object { $_.Definition -eq $firstToken }
            
            if ($aliasMatches -and ($firstToken.Length - $aliasMatches[0].Name.Length) -ge 4) {
                Write-Host "`nFound existing alias for `"$firstToken`". You should use: " -NoNewline -ForegroundColor Yellow
                $aliasNames = $aliasMatches | ForEach-Object { "`"$($_.Name)`"" }
                Write-Host ($aliasNames -join ", ") -ForegroundColor Magenta
            }
        }
    }
    catch {
        Write-Debug "Error in Test-CommandAlias: $_"
    }
}

# ----------------------------
# Configuración del hook
# ----------------------------
function Set-AliasFinderHook {
    param([switch]$Enable, [switch]$Disable)
    
    if ($Disable) {
        Set-PSReadLineKeyHandler -Key Enter -Function AcceptLine
        Write-Host "Alias finder deshabilitado." -ForegroundColor Yellow
        return
    }
    
    if (Get-Module PSReadLine -ErrorAction SilentlyContinue) {
        Set-PSReadLineKeyHandler -Key Enter -BriefDescription "AliasFinder" -ScriptBlock {
            $line = $null
            $cursor = $null
            [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
            
            if (-not [string]::IsNullOrWhiteSpace($line)) {
                Test-CommandAlias -Command $line
            }
            
            [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
        }
        
        if ($Enable) {
            Write-Host "Alias finder habilitado." -ForegroundColor Green
        }
    }
}

# ----------------------------
# Configuración
# ----------------------------
function Set-AliasFinderConfig {
    param([switch]$AutoLoad)
    
    $global:AliasFinderConfig = @{ AutoLoad = $AutoLoad.IsPresent }
    
    if ($AutoLoad) {
        Set-AliasFinderHook -Enable
    } else {
        Set-AliasFinderHook -Disable
    }
}

# ----------------------------
# Alias e inicialización
# ----------------------------
Set-Alias -Name af -Value Find-Alias -ErrorAction SilentlyContinue
Set-Alias -Name alias-finder -Value Find-Alias -ErrorAction SilentlyContinue

$global:AliasFinderConfig = @{ AutoLoad = $true }

if ($global:AliasFinderConfig.AutoLoad -and (Get-Module PSReadLine -ErrorAction SilentlyContinue)) {
    Set-AliasFinderHook
}
Measure-Block "PSAliasFinder"

# ----------------------------
# Integración con Everything para búsqueda de archivos en el sistema
# ----------------------------
function Find-Everything {
    param (
        [Parameter(Mandatory=$true)]
        [string]$SearchTerm,
        [switch]$Files,
        [switch]$Folders,
        [switch]$Regex
    )
    
    $arguments = @()
    
    if ($Files) { $arguments += "-files" }
    if ($Folders) { $arguments += "-folders" }
    if ($Regex) { $arguments += "-regex" }
    
    $arguments += $SearchTerm
    
    # Verifica si es.exe está disponible
    if (Get-Command es -ErrorAction SilentlyContinue) {
        & es.exe $arguments
    } else {
        Write-Host "La utilidad 'es.exe' de Everything no está instalada o no está en el PATH." -ForegroundColor Red
        Write-Host "Descárguela desde: https://www.voidtools.com/support/everything/command_line_interface/" -ForegroundColor Yellow
    }
}

# ============================
# Funciones para manejo de archivos
# ============================

# ----------------------------
# Función: Open-Notepadpp - Integración con Notepad++
# ----------------------------
function Open-Notepadpp { 
    param([Parameter(ValueFromRemainingArguments=$true)]$files)
    
    # Verificar si Notepad++ está instalado
    if (-not (Test-Path "C:\Program Files\Notepad++\notepad++.exe")) {
        Write-Host "Notepad++ no está instalado en la ruta estándar." -ForegroundColor Yellow
        return
    }
    
    # Abrir el archivo con Notepad++
    & "C:\Program Files\Notepad++\notepad++.exe" $files
}

# ----------------------------
# Función: ezall - Listado enriquecido de archivos (eza en ZSH)
# ----------------------------
function ezall {
    param($Path = ".\")
    # Verificar si eza está instalado
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Write-Host "eza no está instalado. Usando Get-ChildItem como alternativa." -ForegroundColor Yellow
        Write-Host "Para instalar eza, visite: https://github.com/eza-community/eza/releases" -ForegroundColor Cyan
        Get-ChildItem -Path $Path -Force | Format-Table -AutoSize
        return
    }
    
    if (-Not (Test-Path $Path)) {
        Write-Host "El directorio especificado no existe: $Path" -ForegroundColor Red
        return
    }
    eza -lagMh --group-directories-first --icons=always --git --git-repos --time-style='+%d/%m/%Y %H:%M' $Path
}

# Alias adicionales para eza (similar a ZSH)
function ezl { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." | Format-Table -AutoSize
        return
    }
    eza -lbF --icons --git 
}

function ezll { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." | Format-Table -AutoSize
        return
    }
    eza -lbGF --icons --git 
}

function ezlm { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." | Sort-Object LastWriteTime | Format-Table -AutoSize
        return
    }
    eza -lbGd --icons --git --sort=modified 
}

function ezla { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." -Force | Format-Table -AutoSize
        return
    }
    eza -lbhHigUmuSa --icons --time-style=long-iso --git --color-scale 
}

function ezlx { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." -Force | Format-Table -AutoSize
        return
    }
    eza -lbhHigUmuSa@ --icons --time-style=long-iso --git --color-scale 
}

function ezS { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." | Format-Wide -Column 1
        return
    }
    eza -1 --icons 
}

function ezt { 
    if (-not (Get-Command eza -ErrorAction SilentlyContinue)) {
        Get-ChildItem -Path "." -Recurse -Depth 2 | Format-Table -AutoSize
        return
    }
    eza --tree --icons --level=2 
}

# ----------------------------
# Navegación rápida (implementación básica)
# ----------------------------
function prog { Set-Location -Path "C:\git" }  # Adaptado - cambie a su ruta equivalente

# ============================
# Funciones y alias para Docker
# ============================

# ----------------------------
# Funciones Docker (replicando la experiencia de ZSH)
# ----------------------------
function dbash {
    param ([Parameter(Mandatory=$true)][string]$Container)
    docker exec -it $(docker ps -aqf "name=$Container") bash
}

function dsh {
    param ([Parameter(Mandatory=$true)][string]$Container)
    docker exec -it $(docker ps -aqf "name=$Container") sh
}

function dnames {
    $containers = docker ps --format "{{.Names}}"
    if ($containers) { $containers } else { Write-Host "No hay contenedores en ejecución" -ForegroundColor Yellow }
}

function dip {
    Write-Host "IP addresses of all named running containers" -ForegroundColor Cyan
    $output = @()
    
    foreach ($name in dnames) {
        if ($name) {
            $ip = docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' $name
            $output += [PSCustomObject]@{
                Container = $name
                IPAddress = $ip
            }
        }
    }
    
    $output | Format-Table -AutoSize
}

function dex {
    param (
        [Parameter(Mandatory=$true)][string]$Container,
        [string]$Shell = "bash"
    )
    docker exec -it $Container $Shell
}

function di {
    param ([Parameter(Mandatory=$true)][string]$Container)
    docker inspect $Container
}

function dl {
    param ([Parameter(Mandatory=$true)][string]$Container)
    docker logs -f $Container
}

function drun {
    param (
        [Parameter(Mandatory=$true)][string]$Image,
        [string]$Command = ""
    )
    docker run -it $Image $Command
}

function dcr {
    docker compose run $args
}

function dsr {
    param ([Parameter(Mandatory=$true)][string]$Container)
    docker stop $Container
    docker rm $Container
}

function drmc {
    $exited = docker ps -q -f status=exited
    if ($exited) {
        docker rm $exited
    } else {
        Write-Host "No hay contenedores detenidos para eliminar" -ForegroundColor Yellow
    }
}

function drmid {
    $dangling = docker images -q -f dangling=true
    if ($dangling) {
        docker rmi $dangling
    } else {
        Write-Host "No hay imágenes huérfanas para eliminar" -ForegroundColor Yellow
    }
}

function dlab {
    param ([Parameter(Mandatory=$true)][string]$Label)
    docker ps --filter="label=$Label" --format="{{.ID}}"
}

# ============================
# Funciones para Git
# ============================
function ga {
    param([string]$Path = ".")
    git add $Path
}

function gpull { git pull }
function gpush { git push }

function gcom {
    param([Parameter(Mandatory = $true)][string]$Message)
    git commit -m $Message
}

# ----------------------------
# Función: updateall - Actualización general
# ----------------------------
function updateall {
    Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Por favor, ejecuta PowerShell como administrador para actualizar todo." -ForegroundColor Red
        return
    }

    # Actualizaciones de Windows Update
    Get-WindowsUpdate -Category Security | Where-Object {$_.Title -match "Defender"} | Install-WindowsUpdate -Verbose -AcceptAll -IgnoreReboot

    # Actualizaciones de Winget
    winget upgrade --all --include-unknown
}

# ----------------------------
# Función: Search-HistoryWithEverything 
# ----------------------------
function Search-HistoryWithEverything {
    if (Get-Command es -ErrorAction SilentlyContinue) {
        Get-History | Select-Object -ExpandProperty CommandLine | ForEach-Object { $_ | es -regex | Out-Host }
    } else {
        Write-Host "Everything CLI no está configurado correctamente." -ForegroundColor Red
    }
}


# ============================
# Funciones para Python (uv)
# ============================

# Activar entorno virtual
function uvs {
    try {
        if (-Not (Test-Path .\.venv\Scripts\Activate.ps1)) {
            Write-Host "No se encontró el entorno virtual en '.venv'. ¿Lo has creado?" -ForegroundColor Yellow
            return
        }
        & .\.venv\Scripts\Activate.ps1
    } catch {
        Write-Host "Error al activar el entorno virtual: $_" -ForegroundColor Red
    }
}

# Ejecutar tareas
function uvt { uv run task $Args }

# Ejecutar comandos
function uvr { uv run $Args }

# Añadir paquetes
function uva { uv add $Args }

# ----------------------------
# Alias complementarios para uv
# ----------------------------
$uvAliases = @{
    # Gestión de paquetes
    ui      = "uv install"
    upi     = "uv pip install"
    uu      = "uv uninstall"
    upu     = "uv pip uninstall"
    ua      = "uv add"
    uf      = "uv freeze"
    # Gestión de entornos virtuales
    uvv      = "uv venv"
    uvc     = "uv venv create"
    uvd     = "uv venv remove"  # Cambiado de uvr a uvd para evitar conflicto
    # Pip específicos
    upc     = "uv pip compile"
    ups     = "uv pip sync"
    # Herramientas de desarrollo
    ulint   = "uv run lint"
    utest   = "uv run test"
    uform   = "uv run format"
    udep    = "uv pip compile --upgrade-package"
    # Utilidades
    ureq    = "uv pip freeze > requirements.txt"
    udev    = "uv pip install -e ."
}

# Registrar los alias de uv
foreach ($alias in $uvAliases.GetEnumerator()) {
    Set-Alias -Name $alias.Key -Value $alias.Value -ErrorAction SilentlyContinue
}

# ============================
# Navegación rápida
# ============================

function cg { Set-Location -Path "C:\git" }
function ~ { Set-Location -Path "~" }
function .. { Set-Location -Path ".." }
function ... { Set-Location -Path "../.." }
function .... { Set-Location -Path "../../.." }

# ============================
# Configuración de alias
# ============================

# ----------------------------
# Alias básicos
# ----------------------------
Set-Alias -Name ll -Value ezall                     # Listado completo con git, iconos y timestamps
Set-Alias -Name l -Value ezl                        # Listado básico con iconos y git
Set-Alias -Name lx -Value ezlx                      # Listado extendido con atributos completos
Set-Alias -Name la -Value ezla                      # Listado completo con archivos ocultos y métricas
Set-Alias -Name lt -Value ezt                       # Vista de árbol de directorios
Set-Alias -Name up -Value updateall                 # Actualizar sistema (Windows Update + Winget)
Set-Alias -Name everything-history -Value Search-HistoryWithEverything  # Buscar en historial con Everything
Set-Alias -Name g -Value git                        # Comando git abreviado
Set-Alias -Name ef -Value Find-Everything           # Búsqueda de archivos/carpetas con Everything
Set-Alias -Name npp -Value Open-Notepadpp           # Abrir archivos en Notepad++

# ----------------------------
# Alias Docker
# ----------------------------
Set-Alias -Name dc -Value docker-compose
Set-Alias -Name dcu -Value "docker compose up -d"
Set-Alias -Name dcd -Value "docker compose down"
Set-Alias -Name dps -Value "docker ps"
Set-Alias -Name dpsa -Value "docker ps -a"
Set-Alias -Name dim -Value "docker images"
Set-Alias -Name dsp -Value "docker system prune --all"

# ----------------------------
# Alias para Poetry
# ----------------------------
$poetryAliases = @{
    pad    = "poetry add"
    pbld   = "poetry build"
    pch    = "poetry check"
    pcmd   = "poetry list"
    pconf  = "poetry config --list"
    pexp   = "Export-PoetryRequirements"
    pin    = "poetry init"
    pinst  = "poetry install"
    plck   = "poetry lock"
    pnew   = "poetry new"
    ppath  = "poetry env info --path"
    pplug  = "poetry self show plugins"
    ppub   = "poetry publish"
    prm    = "poetry remove"
    prun   = "poetry run"
    psad   = "poetry self add"
    psh    = "poetry shell"
    pshw   = "poetry show"
    pslt   = "poetry show --latest"
    psup   = "poetry self update"
    psync  = "poetry install --sync"
    ptree  = "poetry show --tree"
    pup    = "poetry update"
    pvinf  = "poetry env info"
    pvoff  = "poetry config virtualenvs.create false"
    pvrm   = "poetry env remove"
    pvu    = "poetry env use"
}

foreach ($alias in $poetryAliases.GetEnumerator()) {
    Set-Alias -Name $alias.Key -Value $alias.Value
}
Measure-Block "Functions & Aliases"

# Mostrar el tiempo que tardó en cargar el perfil
Show-ProfileLoadTime

# ============================
# REQUISITOS DEL PERFIL
# ============================
# Esta sección lista todos los módulos y programas necesarios para 
# aprovechar completamente este perfil de PowerShell.
#
# MÓDULOS DE POWERSHELL (instalar con Install-Module):
# - PSReadLine        : Install-Module -Name PSReadLine -Force -SkipPublisherCheck
# - Terminal-Icons    : Install-Module -Name Terminal-Icons -Scope CurrentUser
# - posh-git          : Install-Module -Name posh-git -Scope CurrentUser
# - PSFzf             : Install-Module -Name PSFzf -Scope CurrentUser
# - syntax-highlighting: Install-Module -Name syntax-highlighting -Scope CurrentUser
# - PSWindowsUpdate   : Install-Module -Name PSWindowsUpdate -Scope CurrentUser
#
# COMANDO DE INSTALACIÓN RÁPIDA (todos los módulos de PowerShell):
# Install-Module -Name PSReadLine -Force -SkipPublisherCheck; 
# Install-Module -Name Terminal-Icons,posh-git,PSFzf,syntax-highlighting,PSWindowsUpdate -Scope CurrentUser -Force
#
# PROGRAMAS EXTERNOS (winget/chocolatey/manual):
# - zoxide (navegación inteligente): winget install ajeetdsouza.zoxide
# - oh-my-posh (tema personalizable): winget install JanDeDobbeleer.OhMyPosh
# - fzf (búsqueda difusa, requerido por PSFzf): winget install junegunn.fzf
# - neofetch (información del sistema): winget install nepnep.neofetch-win
# - eza (alternativa mejorada a ls): No disponible en winget, descargar de:
#   https://github.com/eza-community/eza/releases
# - Everything (búsqueda de archivos): winget install voidtools.Everything
# - es.exe (CLI para Everything): Parte de Everything, también disponible en:
#   https://www.voidtools.com/support/everything/command_line_interface/
#
# COMANDO DE INSTALACIÓN RÁPIDA (todos los programas disponibles en winget):
# winget install ajeetdsouza.zoxide JanDeDobbeleer.OhMyPosh junegunn.fzf nepnep.neofetch-win voidtools.Everything
#
# Para un rendimiento óptimo, se recomienda instalar todos los componentes listados.
# ============================

# ============================
# GUÍA DE ATAJOS Y COMANDOS
# ============================

## ----------------------------
## BÚSQUEDA DE ALIAS AUTOMÁTICA
## ----------------------------
# Funciones disponibles para búsqueda manual de alias:
# - af 'comando'              : Buscar alias útiles para un comando (con criterios selectivos)
# - af 'comando' -Force       : Buscar todos los alias (ignorar criterios selectivos)
# - af 'comando' -Exact       : Buscar coincidencia exacta
# - af 'comando' -Longer      : Incluir alias más largos
# - af 'comando' -Cheaper     : Solo alias más cortos
# - alias-finder 'comando'    : Alias alternativo para Find-Alias
#
# Criterios selectivos aplicados automáticamente:
# - Comando original debe tener al menos 8 caracteres
# - Máximo 1 pipe real y argumentos limitados (comandos complejos se ignoran)
# - El alias debe ahorrar al menos 4 caracteres
#
# Configuración y control:
# - Set-AliasFinderConfig     : Configurar comportamiento automático
# - Set-AliasFinderHook       : Habilitar/deshabilitar detección automática
#
# Configuración por defecto: detección automática habilitada con criterios selectivos
# ============================

# Si esta es la primera vez que usa este perfil, aquí tiene una guía rápida:
# 
## BÚSQUEDA Y NAVEGACIÓN:
# - ef "término"          : Busca archivos/carpetas en todo el sistema con Everything
# - ef -Files "*.pdf"     : Busca solo archivos PDF
# - ef -Folders "proyecto": Busca solo carpetas con "proyecto" en el nombre
# - ef -Regex "\.jpg$"    : Búsqueda con expresiones regulares
# - fh                    : Búsqueda interactiva en historial de comandos (PSFzf)
# - fcd                   : Navegación interactiva entre directorios (PSFzf)
# - fe                    : Selección interactiva de archivos para editar (PSFzf)
# - fkill                 : Terminación interactiva de procesos (PSFzf)
# - fpgrep "texto" .      : Búsqueda de texto en archivos con vista previa (PSFzf)
# - cd proyecto           : Salto rápido a directorios frecuentes con zoxide (reemplaza cd estándar)
# - z proyecto            : Alias alternativo para navegación con zoxide
# - cdz                   : Búsqueda interactiva de directorios con fzf (requiere zoxide + fzf)
# - ..                    : Subir un nivel de directorio
# - ...                   : Subir dos niveles de directorio
# - ....                  : Subir tres niveles de directorio
# - ~                     : Ir al directorio home
# - cg                    : Ir a C:\git (personalizable según su estructura)
# - everything-history    : Buscar en historial con Everything
# - npp "archivo"         : Abrir "archivo" en Notepad++
#
## NAVEGACIÓN INTELIGENTE (ZOXIDE):
# Zoxide reemplaza el comportamiento estándar de 'cd' con navegación inteligente:
# - cd <directorio>       : Navegar normalmente O saltar a directorios frecuentes
# - z <patrón>           : Saltar a directorio que coincida con el patrón
# - cdz                   : Interfaz interactiva con fzf para seleccionar directorio
# - zoxide query --list  : Ver directorios indexados y sus puntuaciones
#
# Nota: zoxide aprende de sus hábitos y mejora las sugerencias con el uso
#
## LISTADO DE ARCHIVOS (EZA):
# - ll                    : Listado detallado con git, iconos y timestamps
# - l                     : Listado básico con iconos y git
# - lt                    : Vista de árbol de directorios (2 niveles)
# - la                    : Listado completo con archivos ocultos y todas las métricas
# - lx                    : Listado extendido con atributos completos y metadatos
# - ezlm                  : Listado ordenado por fecha de modificación
# - ezS                   : Listado simple en una columna
# - ezll                  : Listado largo con grupos
# - ezall                 : Función completa con todos los parámetros
#
## COMANDOS DOCKER:
# - dps                   : Listar contenedores en ejecución (docker ps)
# - dpsa                  : Listar todos los contenedores (docker ps -a)
# - dip                   : Mostrar IPs de contenedores en ejecución
# - dbash <container>     : Ejecutar bash en un contenedor específico
# - dsh <container>       : Ejecutar sh en un contenedor específico
# - dex <container> <cmd> : Ejecutar comando específico en un contenedor
# - dl <container>        : Ver logs de un contenedor en tiempo real
# - drun <imagen> [cmd]   : Ejecutar nueva instancia interactiva de una imagen
# - dnames                : Listar nombres de contenedores en ejecución
# - dsr <container>       : Detener y eliminar un contenedor
# - drmc                  : Eliminar todos los contenedores detenidos
# - drmid                 : Eliminar todas las imágenes huérfanas (dangling)
# - dlab <label>          : Filtrar contenedores por etiqueta
# - dsp                   : Limpiar recursos Docker no utilizados (system prune)
# - dc                    : Alias para docker compose
# - dcu                   : docker compose up -d
# - dcd                   : docker compose down
# - dcr <servicio> <cmd>  : docker compose run
# - di <container>        : Inspeccionar configuración de un contenedor
# - dim                   : Listar imágenes Docker (docker images)
#
## GIT:
# - g <comando>           : Ejecutar comandos de git (g status, g log, etc.)
# - ga [ruta]             : Git add (añade todo '.' si no se especifica ruta)
# - gcom "mensaje"        : Commit con mensaje (git commit -m)
# - gpush                 : Push de cambios al repositorio remoto
# - gpull                 : Pull de cambios del repositorio remoto
#
## PYTHON/ENTORNOS (UV):
# Gestión de entornos virtuales y paquetes con uv:
# - uvs                   : Activar entorno virtual en .venv
# - ui                    : Instalar paquetes (uv install)
# - ua                    : Añadir paquetes al proyecto (uv add)
# - upi                   : Instalar con uv pip (uv pip install)
# - uu                    : Desinstalar paquetes (uv uninstall)
# - upu                   : Desinstalar con uv pip (uv pip uninstall)
# - uf                    : Listar paquetes instalados (uv freeze)
# - uvv                   : Crear entorno virtual (uv venv)
# - uvc                   : Crear entorno virtual explícitamente
# - uvd                   : Eliminar entorno virtual
# - upc                   : Compilar requirements (uv pip compile)
# - ups                   : Sincronizar entorno (uv pip sync)
# - ureq                  : Generar requirements.txt
# - udep                  : Actualizar dependencias específicas
# - utest/ulint/uform     : Ejecutar tests/linters/formatters
# - udev                  : Instalar proyecto en modo desarrollo (-e)
# - uvt <tarea>           : Ejecutar tarea con taskipy/scripts
# - uvr <comando>         : Ejecutar comando en el entorno uv
#
## POETRY (alternativa a UV):
# - pad <paquete>         : Añadir dependencia (poetry add)
# - prm <paquete>         : Eliminar dependencia (poetry remove)
# - pinst                 : Instalar dependencias (poetry install)
# - psh                   : Activar shell de poetry (poetry shell)
# - prun <comando>        : Ejecutar comando en entorno (poetry run)
# - pup                   : Actualizar dependencias (poetry update)
# - ptree                 : Ver árbol de dependencias (poetry show --tree)
# - psync                 : Sincronizar dependencias (poetry install --sync)
# - ppath                 : Ver ruta del entorno virtual (poetry env info --path)
# - pbld                  : Construir el proyecto (poetry build)
# - ppub                  : Publicar en PyPI (poetry publish)
# - pch                   : Verificar configuración (poetry check)
# - plck                  : Actualizar lock file (poetry lock)
# - pshw                  : Mostrar información de paquetes (poetry show)
# - pslt                  : Mostrar últimas versiones (poetry show --latest)
# - pvinf                 : Información del entorno virtual (poetry env info)
# - pvrm                  : Eliminar entorno virtual (poetry env remove)
# - pvu                   : Usar versión específica de Python (poetry env use)
#
## SISTEMA:
# - updateall             : Actualizar Windows Defender y paquetes Winget (requiere admin)
#
## ATAJOS DE TECLADO:
# - Ctrl+R                : Búsqueda interactiva en historial (PSFzf requerido)
# - Ctrl+T                : Completado interactivo de rutas (PSFzf requerido)
# - Flechas arriba/abajo  : Búsqueda en historial basada en lo ya escrito
# - Tab                   : Autocompletado inteligente
# - Ctrl+L                : Limpiar pantalla
# - Enter                 : Acepta línea + detecta alias disponibles (cuando está habilitado)
#
## CONFIGURACIÓN Y HERRAMIENTAS:
# - Set-AliasFinderConfig -AutoLoad  : Habilitar detección automática de alias
# - Set-AliasFinderHook -Enable      : Activar hook de detección manual
# - Set-AliasFinderHook -Disable     : Desactivar detección de alias
# - Get-Alias                        : Ver todos los alias disponibles
# - $ShowLoadingTimes = $true        : Mostrar métricas de carga del perfil
#
## NOTAS IMPORTANTES:
# - Los comandos que requieren programas externos mostrarán advertencias si no están instalados
# - eza, fzf, zoxide y Everything mejoran significativamente la experiencia pero tienen fallbacks
# - El perfil detecta automáticamente qué herramientas están disponibles y se adapta
# - Para mejor rendimiento, instalar todos los componentes listados en "REQUISITOS DEL PERFIL"
# - Usar 'af <comando>' para descubrir alias útiles para comandos largos
#
# ============================
# Fin de la documentación
# ============================
#
# ============================
# Fin del archivo
# ============================