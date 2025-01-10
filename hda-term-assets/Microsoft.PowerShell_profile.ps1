# ============================
# PowerShell Profile Configuration
# ============================

# ----------------------------
# Inicialización de Oh-My-Posh
# ----------------------------
# Personalización del prompt utilizando el tema Powerlevel10k Rainbow
& oh-my-posh --init --shell pwsh --config ~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json | Invoke-Expression

# ----------------------------
# Información del sistema al iniciar la terminal
# ----------------------------
# Muestra información del sistema mediante Neofetch
neofetch

# ----------------------------
# Configuración de variables de entorno
# ----------------------------
set EZA_ICONS_AUTO=auto^1
#set EZA_COLOR_AUTO=always^1
#set EZA_CONFIG_DIR="%USERPROFILE%\.config\eza^1"

# ============================
# Funciones personalizadas
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

# ----------------------------
# Función: ezall
# Descripción: Lista archivos y directorios con información detallada y formato enriquecido.
# Uso: ezall [ruta]
# ----------------------------
function ezall {
    param($Path = ".\")
    if (-Not (Test-Path $Path)) {
        Write-Host "El directorio especificado no existe: $Path" -ForegroundColor Red
        return
    }
    eza -lagMh --group-directories-first --icons=always --git --git-repos --time-style='+%d/%m/%Y %H:%M' $Path
}

# ----------------------------
# Función: updateall
# Descripción: Actualiza Windows Defender y paquetes Winget.
# Uso: updateall
# ----------------------------
function updateall {
    Import-Module PSWindowsUpdate -ErrorAction SilentlyContinue
    if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
        Write-Host "Por favor, ejecuta PowerShell como administrador para actualizar todo." -ForegroundColor Red
        return
    }

    # Actualizaciones de Windows Update
    Get-WindowsUpdate -Category Security | Where-Object {$_.Title -match "Defender"} | Install-WindowsUpdate -Verbose -AcceptAll -IgnoreReboot

    # Actualizaciones de Winget (problemas para usar | Tee-Object dado que no pinta correctamente en pantalla interactiva)
    winget upgrade --all --include-unknown #| Tee-Object -FilePath "~/winget-upgrade.log"
}

# ----------------------------
# Función: uvs
# Descripción: Activa un entorno virtual de Python en la carpeta actual.
# Uso: uvs
# ----------------------------
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

# ----------------------------
# Función: uvr
# Descripción: Ejecuta 'uv run' con argumentos personalizados.
# Uso: uvr [comando]
# ----------------------------
function uvr {
    uv run $Args
}

# ----------------------------
# Función: uva
# Descripción: Ejecuta 'uv add' con argumentos personalizados.
# Uso: uva [comando]
# ----------------------------
function uva {
    uv add $Args
}

# ----------------------------
# Función: Invoke-CommandWithAliasCheck
# Descripción: Avisa sobre alias disponibles y ejecutar el comando.
# Uso: -
# ----------------------------
function Invoke-CommandWithAliasCheck {
    param (
        [string]$Command
    )
    $commandParts = $Command -split ' ', 2
    $commandName = $commandParts[0]
    $commandArgs = if ($commandParts.Count -gt 1) { $commandParts[1] } else { "" }

    $alias = Get-Alias | Where-Object { $_.Definition -eq $commandName }
    if ($alias) {
        Write-Host "Alias disponible: '$($alias.Name)' para el comando '$commandName'" -ForegroundColor Yellow
    }

    Invoke-Expression $Command
}

 
# ----------------------------
# Función: Search-HistoryWithEverything
# Descripción: Búsqueda interactiva con Everything.
# Uso: -
# ----------------------------
function Search-HistoryWithEverything {
    if (Get-Command es -ErrorAction SilentlyContinue) {
        Get-History | Select-Object -ExpandProperty CommandLine | ForEach-Object { $_ | es -regex | Out-Host }
    } else {
        Write-Host "Everything CLI no está configurado correctamente." -ForegroundColor Red
    }
}
Set-Alias -Name everything-history -Value Search-HistoryWithEverything
 
 
# ----------------------------
# Alias personalizados
# ----------------------------
Set-Alias -Name ll -Value ezall
Set-Alias -Name up -Value updateall

# Alias para Poetry
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

# Alias adicionales
Set-Alias -Name dc -Value docker-compose

# Alias y funciones para git
Set-Alias -Name g -Value git

# ga: git add (con comportamiento predeterminado de añadir todo si no se especifica ruta)
function ga {
    param(
        [string]$Path = "."
    )
    git add $Path
}

# gp: git pull
function gpull {
    git pull
}

# gph: git push
function gpush {
    git push
}

# gm: git commit con mensaje
function gcom {
    param(
        [Parameter(Mandatory = $true)][string]$Message
    )
    git commit -m $Message
}

# Funciones para cambiar de directorio rápidamente

function cg {
    Set-Location -Path "C:\git"
}

function ~ {
    Set-Location -Path "~"
}

function .. {
    Set-Location -Path ".."
}

function ... {
    Set-Location -Path "../.."
}

function .... {
    Set-Location -Path "../../.."
}


# ============================
# Carga de módulos condicional
# ============================
if (CanUsePredictionSource) {
    Import-Module -Name Terminal-Icons
    Import-Module PSReadLine
    Import-Module posh-git
    Import-Module PSWindowsUpdate
    Import-Module wt-shell-integration
    Import-Module syntax-highlighting

    Set-PSReadLineOption -PredictionViewStyle ListView -PredictionSource History -HistoryNoDuplicates -EditMode Windows
    Set-PSReadLineOption -Colors @{
        "Command"        = "`e[38;5;82m"   # Verde
        "Parameter"      = "`e[38;5;220m"  # Amarillo
        "String"         = "`e[38;5;214m"  # Naranja
        "Operator"       = "`e[38;5;81m"   # Azul
    }
    Set-PSReadlineKeyHandler -Key Tab -Function Complete
    Set-PSReadlineKeyHandler -Key Ctrl+r -Function ReverseSearchHistory
    Set-PSReadlineKeyHandler -Key Ctrl+l -Function ClearScreen
    Set-PSReadLineOption -BellStyle None
}
# ============================
# Fin del archivo
# ============================