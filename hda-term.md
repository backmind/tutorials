# Configuración de Terminal y PowerShell
He decidido actualizar y traducir el [gist](https://gist.github.com/backmind/7fcba7ebbb25b4d1ee8513b81ac39579) que tengo sobre la configuración de mi terminal y mi perfil de powershell.
![](https://github.com/backmind/tutorials/blob/main/hda-term-assets/SS1.png)![](https://github.com/backmind/tutorials/blob/main/hda-term-assets/SS2.png)![](https://github.com/backmind/tutorials/blob/main/hda-term-assets/SS3.png)
Si deseas personalizar tu terminal y experiencia en PowerShell, esta guía te llevará paso a paso a través del proceso. Utilizaremos herramientas como Oh My Posh, Terminal-Icons y PowerShell 7.

**Nota:** Esta guía está diseñada para usuarios de Windows 10 o posterior.

---

## Instalación

Abre PowerShell como administrador y ejecuta los siguientes comandos para instalar las herramientas necesarias:

```powershell
winget install --id=Microsoft.WindowsTerminal -e
Install-Module posh-git -Scope CurrentUser
winget install nepnep.neofetch-win
winget install eza-community.eza
winget install JanDeDobbeleer.OhMyPosh -s winget
Install-Module -Name PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck
Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser
Install-Module -Name PSWindowsUpdate
Install-Module -Name syntax-highlighting
Install-Module -Name wt-shell-integration
```

---

## Fuentes

Para utilizar Oh My Posh con fuentes personalizadas, necesitarás una Nerd Font. Recomiendola fuente `SpaceMono NF`, pero escoge la que más te guste. Puedes hacerlo de dos maneras:

### (Opción 1) Instalación automática
1. Abre una consola elevada.
2. Ejecuta: `oh-my-posh font install SpaceMono`.

### (Opción 2) Instalación manual
1. Descarga la fuente desde [nerd-fonts](https://github.com/ryanoasis/nerd-fonts), por ejemplo [SpaceMono.zip](https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/SpaceMono.zip).
2. Extrae los archivos `.ttf`.
3. Haz clic derecho en cada archivo `.ttf` y selecciona "Instalar".

Configura la fuente como predeterminada en Windows Terminal. Edita el archivo `hda-term-assets/settings.json` y establece `"fontFace": "SpaceMono NF"` en la sección "defaults".

---

## Integración con Notepad++

Para abrir archivos desde la terminal con Notepad++ puedes copiar el archivo `hda-term-assets/npp.bat` en la carpeta de Windows o crearlo por ti mismo:
1. Crea un archivo llamado `npp.bat` en `C:\Windows`.
2. Añade esta línea: `"C:\Program Files\Notepad++\notepad++.exe" %*`.
3. Guarda el archivo. Ahora puedes usar `npp archivo.txt` para abrir `archivo.txt`.

---

## Temas de Oh My Posh

Oh My Posh ofrece múltiples temas. Con `Get-PoshThemes` puedes listarlos. Para esta guía, utilizaremos uno externo que a mi me gusta, el tema `pwsh10k`.

1. Descarga el tema desde [pwsh10k](https://github.com/Kudostoy0u/pwsh10k).
2. Guárdalo como `pwsh10k.omp.json` en tu directorio de usuario (`C:\Users\[tu_usuario]`).

---

## Configuración del perfil de PowerShell

Para aprovechar todas las funcionalidades configuradas:
1. Copia el archivo `hda-term-assets/Microsoft.PowerShell_profile.ps1` a la carpeta `C:\Users\[tu_usuario]\Documents\WindowsPowerShell\`.
2. Este archivo incluye configuraciones avanzadas como:
   - Cargar el tema personalizado (`pwsh10k`).
   - Comandos adicionales (`ezall`, `updateall`).
   - Alias útiles (`ll`, `up`).
   - Predicción de comandos con PSReadLine.

---

## Configuración de Windows Terminal

Utiliza el archivo `hda-term-assets/settings.json` como plantilla:
1. Copia el archivo en el directorio de configuración de Windows Terminal: `C:\Users\[tu_usuario]\AppData\Local\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState`.
2. Este archivo incluye:
   - Perfiles personalizados con íconos (`AWS CLI`, `Servidor`, `Anaconda`).
   - Temas predefinidos.
   - Atajos de teclado para mejorar la productividad.

Asegúrate de ajustar las rutas a las herramientas según tu configuración.

---

## Conclusión

Con esta guía, deberías tener una terminal y PowerShell completamente personalizadas y funcionales. Si tienes problemas, consulta la documentación oficial de las herramientas usadas.

### Fuentes
- [Oh My Posh](https://github.com/JanDeDobbeleer/oh-my-posh2)
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons)
- [PSReadLine](https://github.com/PowerShell/PSReadLine)
- [pwsh10k](https://github.com/Kudostoy0u/pwsh10k)
- [eza](https://github.com/eza-community)
- [Windows Terminal Documentation](https://aka.ms/terminal-documentation)
