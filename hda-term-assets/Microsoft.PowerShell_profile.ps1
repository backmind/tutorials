# ============================
# PowerShell Profile Configuration
# ============================

# ============================
# Ajuste para mejorar el tiempo de carga
# ============================

# Iniciando medición de tiempo
$profileStartTime = Get-Date

# Función para mostrar el tiempo de carga
function Show-ProfileLoadTime {
    $loadTime = (Get-Date) - $profileStartTime
    $milliseconds = [math]::Round($loadTime.TotalMilliseconds)
    
    # Solo mostrar si excede 1 segundo (1000ms)
    if ($milliseconds -gt 1000) {
        Write-Host "Perfil de PowerShell cargado en $milliseconds ms." -ForegroundColor Yellow
    }
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

# ============================
# Carga de módulos y configuración
# ============================
if (CanUsePredictionSource) {
    # Carga de módulos
    Import-Module -Name Terminal-Icons
    Import-Module PSReadLine
    Import-Module posh-git
    Import-Module PSWindowsUpdate
    Import-Module wt-shell-integration
    Import-Module syntax-highlighting
    
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
    Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadlineKeyHandler -Key Ctrl+l -Function ClearScreen
    Set-PSReadlineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadlineKeyHandler -Key DownArrow -Function HistorySearchForward
    Set-PSReadLineOption -BellStyle None
}

# ============================
# Utilidades avanzadas 
# ============================

# ----------------------------
# Función: Test-CommandAlias
# Descripción: Comprueba si un comando tiene alias disponibles y muestra recomendaciones
# ----------------------------
function Test-CommandAlias {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Command
    )
    
    try {
        # Extraer el primer token (comando principal)
        $commandParts = $Command -split '\s+', 2
        $firstToken = $commandParts[0]
        
        # Ignorar si es muy corto o ya es un alias
        if ($firstToken.Length -le 1) { return }
        
        # Ver si el comando ya es un alias
        $isAlias = $false
        try {
            # Solo verificamos si existe el alias, no necesitamos guardarlo
            $null = Get-Alias -Name $firstToken -ErrorAction Stop
            # Ya es un alias, no hacemos nada
            $isAlias = $true
        }
        catch {
            # No es un alias, continuamos la verificación
        }
        
        # Solo verificamos si NO es un alias
        if (-not $isAlias) {
            # Buscar si el comando tiene alias disponibles
            $availableAliases = @()
            
            # Buscar en alias estándar
            $aliasMatches = Get-Alias | Where-Object { $_.Definition -eq $firstToken }
            if ($aliasMatches) {
                $availableAliases += $aliasMatches
            }
            
            # Buscar en funciones (si el comando coincide con alguna función definida)
            $functionMatches = Get-ChildItem function: | Where-Object { $_.Name -eq $firstToken }
            if ($functionMatches) {
                # Buscar alias que apunten a esta función
                $functionAliases = Get-Alias | Where-Object { $_.Definition -eq "function:$firstToken" }
                if ($functionAliases) {
                    $availableAliases += $functionAliases
                }
            }
            
            # Si se encontraron alias disponibles, mostrar mensaje estilo ZSH
            if ($availableAliases.Count -gt 0) {
                # Construir el mensaje con colores diferenciados
                Write-Host "`nFound existing alias for " -NoNewline -ForegroundColor Yellow
                Write-Host "`"$firstToken`"" -NoNewline -ForegroundColor Magenta
                Write-Host ". You should use: " -NoNewline -ForegroundColor Yellow
                
                # Mostrar cada alias en color morado, separados por comas
                $aliasCount = $availableAliases.Count
                for ($i = 0; $i -lt $aliasCount; $i++) {
                    Write-Host "`"$($availableAliases[$i].Name)`"" -NoNewline -ForegroundColor Magenta
                    
                    # Añadir coma si no es el último alias
                    if ($i -lt $aliasCount - 1) {
                        Write-Host ", " -NoNewline -ForegroundColor Yellow
                    }
                }
                
                # Terminar con un salto de línea
                Write-Host ""
            }
        }
    }
    catch {
        # Silenciar errores para no interferir con la ejecución normal
    }
}

# Configuración del hook para PSReadLine
if (CanUsePredictionSource) {
    Set-PSReadLineKeyHandler -Key Enter -BriefDescription "AliasCheck" -ScriptBlock {
        $line = $null
        $cursor = $null
        [Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$cursor)
        
        if ($line.Trim() -ne "") {
            # Comprobar alias antes de ejecutar
            Test-CommandAlias -Command $line
        }
        
        # Acepta la línea para que PowerShell la ejecute normalmente
        [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
    }
}

# ----------------------------
# Función: Z para navegación rápida entre directorios frecuentes
# ----------------------------
if (Get-Module -ListAvailable -Name z) {
    Import-Module z
} else {
    Write-Host "Para navegación rápida entre directorios frecuentes, considera instalar el módulo 'z': Install-Module -Name z -AllowClobber" -ForegroundColor DarkYellow
    Write-Host "Z memoriza tus directorios visitados y permite saltar a ellos con patrones mínimos (ej: 'z proy' para ir a C:\Users\Username\Projects)" -ForegroundColor DarkYellow
}

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
Set-Alias -Name ll -Value ezall
Set-Alias -Name l -Value ezl
Set-Alias -Name lx -Value ezlx
Set-Alias -Name la -Value ezla
Set-Alias -Name lt -Value ezt
Set-Alias -Name up -Value updateall
Set-Alias -Name everything-history -Value Search-HistoryWithEverything
Set-Alias -Name g -Value git
Set-Alias -Name ef -Value Find-Everything
Set-Alias -Name npp -Value Open-Notepadpp

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
# - z                 : Install-Module -Name z -Scope CurrentUser
# - syntax-highlighting: Install-Module -Name syntax-highlighting -Scope CurrentUser
# - PSWindowsUpdate   : Install-Module -Name PSWindowsUpdate -Scope CurrentUser
#
# COMANDO DE INSTALACIÓN RÁPIDA (todos los módulos de PowerShell):
# Install-Module -Name PSReadLine -Force -SkipPublisherCheck; 
# Install-Module -Name Terminal-Icons,posh-git,PSFzf,z,syntax-highlighting,PSWindowsUpdate -Scope CurrentUser -Force
#
# PROGRAMAS EXTERNOS (winget/chocolatey/manual):
# - oh-my-posh (tema personalizable): winget install JanDeDobbeleer.OhMyPosh
# - fzf (búsqueda difusa, requerido por PSFzf): winget install junegunn.fzf
# - neofetch (información del sistema): winget install neofetch
# - eza (alternativa mejorada a ls): No disponible en winget, descargar de:
#   https://github.com/eza-community/eza/releases
# - Everything (búsqueda de archivos): winget install voidtools.Everything
# - es.exe (CLI para Everything): Parte de Everything, también disponible en:
#   https://www.voidtools.com/support/everything/command_line_interface/
#
# COMANDO DE INSTALACIÓN RÁPIDA (todos los programas disponibles en winget):
# winget install JanDeDobbeleer.OhMyPosh junegunn.fzf neofetch voidtools.Everything
#
# Para un rendimiento óptimo, se recomienda instalar todos los componentes listados.
# ============================

# ============================
# GUÍA DE ATAJOS Y COMANDOS
# ============================

# Si esta es la primera vez que usa este perfil, aquí tiene una guía rápida:
# 
# BÚSQUEDA Y NAVEGACIÓN:
# - ef "término"          : Busca archivos/carpetas en todo el sistema con Everything
# - ef -Files "*.pdf"     : Busca solo archivos PDF
# - ef -Folders "proyecto": Busca solo carpetas con "proyecto" en el nombre
# - ef -Regex "\.jpg$"    : Búsqueda con expresiones regulares
# - fh                    : Búsqueda interactiva en historial de comandos (PSFzf)
# - fcd                   : Navegación interactiva entre directorios (PSFzf)
# - fe                    : Selección interactiva de archivos para editar (PSFzf)
# - fkill                 : Terminación interactiva de procesos (PSFzf)
# - fpgrep "texto" .      : Búsqueda de texto en archivos con vista previa (PSFzf)
# - z proyecto            : Salto rápido a directorios frecuentes (módulo z)
# - ..                    : Subir un nivel de directorio
# - ...                   : Subir dos niveles de directorio
# - ....                  : Subir tres niveles de directorio
# - ~                     : Ir al directorio home
# - cg                    : Ir a C:\git (personalizable)
# - everything-history    : Buscar en historial con Everything
# - npp "archivo"		  : Abrir "archivo" en notepad++
#
# LISTADO DE ARCHIVOS (EZA):
# - ll                    : Listado detallado con git
# - l                     : Listado básico con iconos
# - lt                    : Vista de árbol de directorios
# - la                    : Listado completo con todos los atributos
# - lx                    : Listado extendido con atributos
# - ezlm                  : Listado ordenado por fecha de modificación
# - ezS                   : Listado simple en una columna
#
# COMANDOS DOCKER:
# - dps                   : Listar contenedores en ejecución
# - dpsa                  : Listar todos los contenedores (incluso detenidos)
# - dip                   : Mostrar IPs de contenedores en ejecución
# - dbash <container>     : Ejecutar bash en un contenedor
# - dsh <container>       : Ejecutar sh en un contenedor
# - dex <container> <cmd> : Ejecutar comando específico en un contenedor
# - dl <container>        : Ver logs de un contenedor
# - drun <imagen>         : Ejecutar nueva instancia de una imagen
# - dnames                : Listar nombres de contenedores en ejecución
# - dsr <container>       : Detener y eliminar un contenedor
# - drmc                  : Eliminar todos los contenedores detenidos
# - drmid                 : Eliminar todas las imágenes huérfanas
# - dsp                   : Limpiar recursos Docker no utilizados
# - dc                    : Alias para docker-compose
# - dcu                   : docker compose up -d
# - dcd                   : docker compose down
# - dcr <servicio> <cmd>  : docker compose run
#
# GIT:
# - g <comando>           : Ejecutar comandos de git (g status, g log, etc.)
# - ga [ruta]             : Git add (añade todo si no se especifica ruta)
# - gcom "mensaje"        : Commit con mensaje
# - gpush                 : Push de cambios al repositorio remoto
# - gpull                 : Pull de cambios del repositorio remoto
#
# PYTHON/ENTORNOS (UV):
# - uvs                   : Activar entorno virtual en .venv
# - ui                    : Instalar paquetes (uv install)
# - ua/upi                : Añadir/instalar paquetes
# - uu/upu                : Desinstalar paquetes
# - uf                    : Listar paquetes instalados (freeze)
# - uv/uvc/uvd              : Gestionar/crear/eliminar entornos virtuales
# - upc                   : Compilar requisitos (pip compile)
# - ups                   : Sincronizar entorno (pip sync)
# - ureq                  : Generar requirements.txt (freeze)
# - udep                  : Actualizar dependencias
# - utest/ulint/uform     : Ejecutar tests/linters/formatters
# - udev                  : Instalar proyecto en modo desarrollo (-e)
# - uvt <tarea>           : Ejecutar tarea con taskipy (task)
# - uvr <comando>         : Ejecutar comando genérico en entorno
#
# POETRY:
# - pad <paquete>         : Añadir dependencia (poetry add)
# - prm <paquete>         : Eliminar dependencia (poetry remove)
# - pinst                 : Instalar dependencias (poetry install)
# - psh                   : Activar shell de poetry (poetry shell)
# - prun <comando>        : Ejecutar comando en entorno (poetry run)
# - pup                   : Actualizar dependencias (poetry update)
# - ptree                 : Ver árbol de dependencias (poetry show --tree)
# - psync                 : Sincronizar dependencias (poetry install --sync)
# - ppath                 : Ver ruta del entorno virtual (poetry env info --path)
#
# SISTEMA:
# - updateall             : Actualizar Windows Defender y paquetes de Winget
#
# ATAJOS DE TECLADO:
# - Ctrl+R                : Búsqueda interactiva en historial (si PSFzf está instalado)
# - Ctrl+T                : Completado interactivo de rutas (si PSFzf está instalado)
# - Flechas arriba/abajo  : Búsqueda en historial basada en lo escrito hasta el momento
# - Tab                   : Autocompletado inteligente
# - Ctrl+L                : Limpiar pantalla
#
# Consejo: Para ver todos los alias disponibles, ejecute: Get-Alias
#
# ============================
# Fin del archivo
# ============================

# Mostrar el tiempo que tardó en cargar el perfil
Show-ProfileLoadTime