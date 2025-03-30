![](https://github.com/backmind/tutorials/blob/main/hda-term-assets/logo.png)

# Configuración de Terminal y PowerShell: Una Guía Completa

He decidido actualizar y traducir el [gist](https://gist.github.com/backmind/7fcba7ebbb25b4d1ee8513b81ac39579) que tengo sobre la configuración de mi terminal (Windows Term) y mi perfil de PowerShell, añadiendo todas las mejoras que he implementado recientemente. Cabe destacar que en el hilo-guía sobre el homelab [hda-serv]() dejo una configuración del .zshrc, que en cierto modo podría ser análoga a la configuración del PowerShell aquí.

Este tuto se engloba en los otros de la serie:

1. Capa de Backup (hda-nas): La base física que garantiza la persistencia y seguridad de datos.
2. Capa de Computación (hda-serv): El motor que proporciona recursos de procesamiento y virtualización.
3. **Capa de Interfaz (hda-term)**: El punto de entrada y gestión para administración eficiente.
4. Capa de Servicios (hda-svc) (en desarrollo): La capa de aplicación donde el valor práctico se materializa a través de múltiples servicios especializados.


# Nota
Antes de continuar, como siempre, debo comentar que no soy ningún experto a bajo nivel en la materia. Tengo nociones de sistemas operativos y línea de comandos, pero para nada soy profesional de sistemas ni de coña. Mi trasfondo es de programador y de físico, aunque siempre he sido entusiasta de la informática y desde pequeño me he dedicado a montar, desmontar y formatear mis ordenadores. Todo esto lo comparto como aficionado que disfruta optimizando su entorno de trabajo para aumentar la eficiencia y la comodidad.

Lo que quiero decir con esto es que lo que comparto puede estar errado. Por favor, si encontráis algún error de contenido o forma, hacédmelo saber ya sea por comentarios o haciéndome un [PR](https://github.com/backmind/tutorials). Este tutorial es simplemente una guía de configuración para tener un terminal más eficiente y personalizado en Windows.

# 1. Índice
1. [Índice](#1-índice)
2. [Preámbulo](#2-preámbulo)
   1. [Motivación](#21-motivación)
   2. [¿Qué es un terminal personalizado?](#22-qué-es-un-terminal-personalizado)
3. [Instalación de componentes](#3-instalación-de-componentes)
   1. [Componentes esenciales](#31-componentes-esenciales)
   2. [Módulos de PowerShell](#32-módulos-de-powershell)
   3. [Herramientas externas](#33-herramientas-externas)
4. [Configuración de fuentes](#4-configuración-de-fuentes)
   1. [Instalación automática](#41-instalación-automática)
   2. [Instalación manual](#42-instalación-manual)
   3. [Configuración en Windows Terminal](#43-configuración-en-windows-terminal)
5. [Temas de Oh My Posh](#5-temas-de-oh-my-posh)
6. [Configuración del perfil de PowerShell](#6-configuración-del-perfil-de-powershell)
   1. [Instalación del perfil](#61-instalación-del-perfil)
   2. [Características principales](#62-características-principales)
   3. [Funciones y alias destacados](#63-funciones-y-alias-destacados)
7. [Configuración de Windows Terminal](#7-configuración-de-windows-terminal)
8. [Herramientas avanzadas](#8-herramientas-avanzadas)
   1. [PSFzf: Búsqueda interactiva](#81-psfzf-búsqueda-interactiva)
   2. [Z: Navegación rápida entre directorios](#82-z-navegación-rápida-entre-directorios)
   3. [UV: Gestión de entornos Python](#83-uv-gestión-de-entornos-python)
9. [Flujos de trabajo optimizados](#9-flujos-de-trabajo-optimizados)
	1. [Desarrollo con Git y Docker](#91-desarrollo-con-git-y-docker)
	2. [Administración del sistema](#92-administración-del-sistema)
10. [Palabras finales](#10-palabras-finales)
    1. [Guía de atajos y comandos](#101-guía-de-atajos-y-comandos)
    2. [Para el futuro](#102-para-el-futuro)

# 2. Preámbulo

## 2.1 Motivación

<img src="https://github.com/backmind/tutorials/blob/main/hda-term-assets/IMG1.png" style="width:100%; height:auto;">
*Comparativa entre la terminal predeterminada de Windows (izquierda) y nuestra configuración personalizada (derecha), mostrando las diferencias en legibilidad, información contextual y estética.*

Como entusiasta de la informática, siempre he buscado formas de hacer mi interacción con el ordenador más cómoda y eficiente. La línea de comandos es una herramienta fundamental para cualquier persona que trabaje intensivamente con un pc y, en Windows, el terminal predeterminado puede quedarse corto en cuanto a funcionalidades y estética.*

Esta guía nace de mi deseo de compartir una configuración que he ido refinando con el tiempo, buscando no solo mejorar la apariencia de la terminal sino, sobre todo, aumentar mi productividad diaria a través de funcionalidades avanzadas, atajos inteligentes y herramientas modernas que hacen de PowerShell un entorno mucho más potente.

**Este tutorial representa la tercera capa de mi arquitectura personal de computación. Si en hda-nas establecí la capa de almacenamiento seguro y redundante (la base física) y en hda-serv desarrollé la capa de computación y servicios (el motor), aquí abordo la capa de interfaz humano-máquina. Esta progresión lógica sigue un patrón similar al de cualquier arquitectura informática robusta: primero aseguramos los datos, luego configuramos el procesamiento, y finalmente optimizamos la interacción. El terminal es mi principal punto de contacto con todo el sistema, por lo que su configuración óptima multiplica la eficiencia de las capas anteriores y sienta las bases para la capa final de servicios específicos (hda-svc) que desarrollaré en el próximo tutorial.**

## 2.2 ¿Qué es un terminal personalizado?

Un terminal personalizado va más allá de la simple consola de comandos predeterminada. Incluye mejoras estéticas como temas de colores, información visual del sistema y de repositorios git, pero también mejoras funcionales como autocompletado inteligente, predicción de comandos, búsqueda interactiva en el historial, y atajos de teclado eficientes.

Las ventajas de un terminal bien configurado incluyen:
- Mayor productividad al reducir la cantidad de texto que necesitas escribir
- Mejor visualización de información crítica (estados de git, rutas, errores)
- Experiencia más agradable que incentiva el uso de la línea de comandos
- Funcionalidades avanzadas que facilitan tareas complejas

# 3. Instalación de componentes

Antes de empezar, doy por hecho que tienes corriendo y funcionando [winget](https://learn.microsoft.com/es-es/windows/package-manager/winget). Winget es un gestor de instalación por consola que viene ya integrado con Windows 11, en anteriores versiones del OS hay que instalarlo [a mano](https://aka.ms/getwingetpreview). Es análogo a apt-get de Debian, por ejemplo. Existe otra herramienta en el ecosistema Windows (no oficial) que durante años sirvió para hacer la instalación básica de aplicaciones en windows: [Ninite](https://ninite.com/). Hoy por hoy, Ninite pierde todo el sentido, pues gracias a winget puedes instalar lo que quieras (ya sea desde repos oficiales de windows, o desde github) por lo que el universo de aplicaciones es total, frente a las 87 que te permite Ninite. El uso básico de winget no tiene dificultad. Así se instalaría un programa:

```winget install Google.Chrome```

También puedes poner todos los programas que desees (como ese "Google.Chrome" del ejemplo de arriba) en un archivo de texto y ejecutar:

```winget import archivo.txt```

Para hacerlo más sencillo todavía, para "doble click", te montas un archivo bat de la forma:

``@echo off
winget import archivo.txt``

Y lo guardas como ```miPropioAppsBasicas.bat```, y al lado ```archivo.txt``` con las app que quieras. Más info [aquí](https://learn.microsoft.com/es-es/windows/package-manager/winget/).

Una de las cosas más relevantes de winget es que puedes invocar la siguiente expresión para que te actualice todas las apps del sistema: ```winget update --all```

Para este tutorial usaremos en la línea de comandados Winget para instalar las dependencias.


## 3.1 Componentes esenciales

Empezamos abriendo PowerShell como administrador y ejecuntando los siguientes comandos para instalar las herramientas básicas necesarias: El terminal de windows, la última versión de powershell, una capa gráfica para powershell, un visualizador de sistema/recursos y un programa actual para hacer ls/dir:

```powershell
# Instalar Windows Terminal
winget install --id=Microsoft.WindowsTerminal -e

# Instalar PowerShell 7 (si aún no lo tienes)
winget install --id Microsoft.PowerShell -e

# Instalar Oh My Posh para personalización del prompt
winget install JanDeDobbeleer.OhMyPosh -s winget

# Instalar Neofetch para información del sistema
winget install nepnep.neofetch-win

# Instalar eza, alternativa mejorada a ls
winget install eza-community.eza
```

## 3.2 Módulos de PowerShell

Los sigueintes módulos extienden significativamente las capacidades de PowerShell:

```powershell
# Módulos esenciales
## Mejora la edición de línea de comandos con resaltado de sintaxis y autocompletado avanzado
Install-Module PSReadLine -AllowPrerelease -Scope CurrentUser -Force -SkipPublisherCheck  
## Integración de Git en PowerShell con información de estado y autocompletado
Install-Module posh-git -Scope CurrentUser
## Añade iconos visuales a archivos y directorios en la terminal
Install-Module Terminal-Icons -Repository PSGallery -Scope CurrentUser 

# Módulos para funcionalidades adicionales
## Gestión de actualizaciones de Windows desde PowerShell
Install-Module PSWindowsUpdate -Scope CurrentUser
## Proporciona resaltado de sintaxis adicional para código
Install-Module syntax-highlighting -Scope CurrentUser
## Integración avanzada con Windows Terminal
Install-Module wt-shell-integration -Scope CurrentUser
## Búsqueda difusa interactiva
Install-Module PSFzf -Scope CurrentUser
## Navegación rápida entre directorios
Install-Module z -Scope CurrentUser
```

## 3.3 Herramientas externas

Algunas herramientas adicionales que mejorarán tu experiencia. Sobre mi uso de everything recomiendo la integración de la experiencia con [flow.launcher](https://www.flowlauncher.com/); esto trasciende la configuración de una consola, pero me gustaría dejar el comentario aquí.

```powershell
# Instalar fzf (requerido por PSFzf)
winget install junegunn.fzf

# Instalar Everything (opcional, para búsqueda rápida de archivos)
winget install voidtools.Everything
```

# 4. Configuración de fuentes
<img src="https://github.com/backmind/tutorials/blob/main/hda-term-assets/SSFonts.png" style="width:75%; height:auto;">
*Panel de configuración de fuentes en Windows Terminal mostrando 'SpaceMono NF' seleccionada como fuente predeterminada.*

Para utilizar Oh My Posh con todos sus glifos e iconos necesitarás una [Nerd Font](https://www.nerdfonts.com/). Recomiendo la fuente `SpaceMono NF`, pero puedes escoger la que más te guste.

## 4.1 Instalación automática

La forma más sencilla es usar el propio Oh My Posh para instalar la fuente:

1. Abre una consola con privilegios de administrador
2. Ejecuta: `oh-my-posh font install SpaceMono`

## 4.2 Instalación manual

Si prefieres hacerlo manualmente:

1. Descarga la fuente desde [nerd-fonts](https://github.com/ryanoasis/nerd-fonts), por ejemplo [SpaceMono.zip](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.3.0/SpaceMono.zip)
2. Extrae los archivos `.ttf`
3. Haz clic derecho en cada archivo `.ttf` y selecciona "Instalar"

## 4.3 Configuración en Windows Terminal

Una vez instalada la fuente, necesitas configurarla como predeterminada en Windows Terminal:

1. Abre Windows Terminal
2. Pulsa `Ctrl+,` o abre el menú desplegable y selecciona "Configuración"
3. En "Valores predeterminados" > "Apariencia", cambia la fuente a "SpaceMono NF"
4. Alternativamente, puedes utilizar directamente el archivo [settings.json](https://github.com/backmind/tutorials/blob/main/hda-term-assets/settings.json) que está en la carpeta hda-term-assets del repositorio como punto de partida para tu configuración

# 5. Temas de Oh My Posh
<img src="https://github.com/backmind/tutorials/blob/main/hda-term-assets/SSTemas.png" style="width:75%; height:auto;">
*Varios temas de Oh My Posh en acción. De arriba a abajo: powerlevel10k_rainbow, atomic, paradox y jandedobbeleer.*

Oh My Posh ofrece múltiples temas que puedes explorar con el comando `Get-PoshThemes`. [Aquí podéis ver varios ejemplos](https://ohmyposh.dev/docs/themes). Para esta guía, utilizaré uno basado en Powerlevel10k, un tema muy popular por su claridad y funcionalidad.

Lo mejor del nuevo perfil es que buscará automáticamente el tema en varias ubicaciones posibles, pero asegúrate de tener al menos uno instalado:

1. El perfil buscará primero: `~/AppData/Local/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json`
2. Si no lo encuentra, usará cualquier tema que contenga "powerlevel10k" en su nombre
3. Como último recurso, utilizará el tema predeterminado

Puedes descargar el tema recomendado y guardarlo en la ubicación apropiada:
```powershell
# Crear directorio si no existe
if (!(Test-Path -Path "$env:LOCALAPPDATA/Programs/oh-my-posh/themes/")) {
    New-Item -ItemType Directory -Path "$env:LOCALAPPDATA/Programs/oh-my-posh/themes/" -Force
}

# Descargar el tema
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/powerlevel10k_rainbow.omp.json" -OutFile "$env:LOCALAPPDATA/Programs/oh-my-posh/themes/powerlevel10k_rainbow.omp.json"
```

# 6. Configuración del perfil de PowerShell

## 6.1 Instalación del perfil

El perfil de PowerShell es un script que se ejecuta cada vez que inicias una nueva sesión. Para utilizar el perfil personalizado:

1. Copia el archivo [Microsoft.PowerShell_profile.ps1](https://github.com/backmind/tutorials/blob/main/hda-term-assets/Microsoft.PowerShell_profile.ps1) desde la carpeta hda-term-assets del repositorio
2. Pégalo en la carpeta adecuada según tu versión de PowerShell:
   - Para PowerShell 7: `$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1`
   - Para PowerShell 5.1: `$HOME\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1`

Si no estás seguro de dónde debe ir el archivo, ejecuta:
```powershell
echo $PROFILE
```

También puedes crear el directorio si no existe:
```powershell
if (!(Test-Path -Path (Split-Path $PROFILE))) {
    New-Item -ItemType Directory -Path (Split-Path $PROFILE) -Force
}
```

## 6.2 Características principales

El perfil de PowerShell incluye numerosas mejoras y características:

1. **Medición de tiempo de carga**: Te informa si el perfil tarda demasiado en cargar
2. **Verificación de módulos**: Comprueba automáticamente si faltan módulos críticos o recomendados
3. **Temas automáticos**: Búsqueda inteligente de temas de Oh My Posh en múltiples ubicaciones
4. **Predicción avanzada**: Configuración optimizada de PSReadLine para predicción de comandos
5. **Búsqueda interactiva**: Integración con PSFzf para búsqueda difusa en historial y archivos
6. **Navegación rápida**: Soporte para el módulo Z que aprende tus directorios más usados
7. **Indicaciones de alias**: Te sugiere cuando hay atajos disponibles para comandos largos
8. **Personalización de colores**: Esquema de colores optimizado para mejor legibilidad
9. **Guía de uso integrada**: Documentación completa de comandos y atajos al final del archivo

## 6.3 Funciones y alias destacados

El perfil incluye numerosas funciones y alias para mejorar tu productividad:

### Herramientas de sistema
- `ezall` / `ll`: Listado detallado de archivos con iconos e información git
- `updateall`: Actualiza Windows Defender y paquetes Winget
- `ef`: Búsqueda rápida de archivos con Everything
- `npp "ARCHIVO"`: Abre "ARCHIVO" con el Notepad++

### Navegación
- `z`: Salto rápido a directorios frecuentes
- `fcd`: Navegación interactiva entre directorios
- `..`, `...`, `....`: Navegar hacia arriba en la jerarquía de directorios
- `~`: Ir al directorio home
- `cg`: Ir a C:\git (personalizable)

### Docker
- `dps`, `dpsa`: Listar contenedores (en ejecución/todos)
- `dbash`, `dsh`: Ejecutar shell en un contenedor
- `drun`: Ejecutar una nueva instancia de una imagen
- `dc`, `dcu`, `dcd`: Comandos docker-compose

### Git
- `g`: Alias para git
- `ga`: Git add
- `gcom`: Git commit con mensaje
- `gpush`, `gpull`: Push/pull de cambios

### Python/UV
- `uvs`: Activar entorno virtual
- `ui`, `upi`: Instalar paquetes
- `uf`: Listar paquetes instalados
- `utest`, `ulint`: Ejecutar tests/linters

### Poetry
- `pinst`: Instalar dependencias
- `psh`: Activar shell de poetry
- `prun`: Ejecutar comando en entorno

# 7. Configuración de Windows Terminal

Windows Terminal es altamente personalizable. Puedes configurarlo editando su archivo `settings.json`:

1. Abre Windows Terminal
2. Pulsa `Ctrl+,` para abrir la configuración
3. Haz clic en "Abrir archivo JSON" en la esquina inferior izquierda

Utiliza el archivo [settings.json](https://github.com/backmind/tutorials/blob/main/hda-term-assets/settings.json) de la carpeta hda-term-assets como plantilla. Este archivo incluye:

- Temas de colores personalizados
- Perfiles para diferentes shells (PowerShell, WSL, Azure, etc.)
- Iconos personalizados para cada perfil
- Atajos de teclado optimizados
- Configuraciones de apariencia

Aspectos destacados a configurar:
```json
"profiles": {
    "defaults": {
        "font": {
            "face": "SpaceMono NF",
            "size": 11
        },
        "opacity": 95,
        "useAcrylic": true
    }
}
```

Puedes ajustar estos valores según tus preferencias personales.

# 8. Herramientas avanzadas

## 8.1 PSFzf: Búsqueda interactiva
<img src="https://github.com/backmind/tutorials/blob/main/hda-term-assets/SSfzf.png" style="width:75%; height:auto;">
*PSFzf en acción: búsqueda interactiva en el historial de comandos con Ctrl+R mostrando resultados filtrados en tiempo real.*

[PSFzf](https://github.com/kelleyma49/PSFzf) es una integración de PowerShell con FZF (Fuzzy Finder), que proporciona una búsqueda interactiva incremental:

```powershell
# Instalar PSFzf si aún no lo has hecho
Install-Module PSFzf -Scope CurrentUser

# Asegúrate de que FZF está instalado
winget install junegunn.fzf
```

Con PSFzf configurado en el perfil, podrás usar:
- `Ctrl+R`: Búsqueda interactiva en el historial de comandos
- `Ctrl+T`: Completado interactivo de rutas de archivo
- `fcd`: Navegación interactiva entre directorios
- `fe`: Selección de archivos para editar
- `fkill`: Terminación interactiva de procesos
- `fpgrep`: Búsqueda de texto en archivos con vista previa

## 8.2 Z: Navegación rápida entre directorios

El módulo [Z](https://github.com/jethrokuan/z) aprende tus patrones de navegación y te permite saltar rápidamente a directorios frecuentes:

```powershell
# Instalar Z si aún no lo has hecho
Install-Module z -Scope CurrentUser -AllowClobber
```

Ejemplos de uso:
- `z down` para ir a ~/Downloads
- `z doc` para ir a ~/Documents
- `z proj` para ir a C:/git/projects
- `z` sin argumentos muestra una lista de directorios frecuentes

## 8.3 UV: Gestión de entornos Python

El perfil incluye alias y funciones para trabajar con [UV](https://github.com/astral-sh/uv), una alternativa moderna a pip. UV destaca por su implementación en Rust que lo hace 10-100 veces más rápido que pip, especialmente en proyectos complejos. Ofrece resolución de dependencias más predecible, instalaciones atómicas que evitan estados inconsistentes, y mantiene compatibilidad total con requirements.txt y pyproject.toml:

```powershell
# Ejemplos de uso de UV
uvs        # Activar entorno virtual en .venv
ui         # uv install - Instalar dependencias
upi        # uv pip install - Instalar paquetes con pip
ua         # uv add - Añadir paquetes
uf         # uv freeze - Listar paquetes
utest      # uv run test - Ejecutar tests
ulint      # uv run lint - Ejecutar linter
uform      # uv run format - Formatear código
```

# 9. Flujos de trabajo optimizados

## 9.1 Desarrollo con Git y Docker

El siguiente ejemplo muestra cómo la configuración permite un flujo de trabajo más ágil:

```powershell
# Antes
cd C:\Users\username\Projects\my-project
git status
docker ps
docker-compose up -d
docker logs -f container_name

# Después
z proj      # Navega a my-project usando Z
g status    # Alias para git status con información visual
dps         # Lista contenedores Docker
dcu         # Levanta contenedores con docker-compose
dl container_name  # Muestra logs del contenedor
```

## 9.2 Administración del sistema

```powershell
# Buscar rápidamente archivos de configuración
ef -Files "*.config"  

# Actualizar todo el sistema
updateall

# Alternativamente puedes usar el siguiente alias
up

# Monitorizar recursos
neofetch
```

# 10. Palabras finales

## 10.1 Guía de atajos y comandos

El perfil de PowerShell incluye una completa guía de uso al final del archivo. Para ver esta documentación, simplemente abre el archivo `Microsoft.PowerShell_profile.ps1` y desplázate hasta la sección `GUÍA DE ATAJOS Y COMANDOS` cerca del final.

Esta documentación integrada incluye:
- Comandos de búsqueda y navegación
- Opciones para listar archivos
- Comandos Docker detallados
- Atajos Git
- Funciones para Python/UV
- Comandos Poetry
- Herramientas de sistema
- Atajos de teclado importantes

Mantener esta guía integrada en el perfil te permite acceder rápidamente a la documentación sin necesidad de recursos externos.

## 10.2 Para el futuro

La configuración de terminales es un proceso en constante evolución. Algunas ideas para futuras mejoras:

1. **Integración con WSL2**: Mejorar la interacción entre PowerShell y distribuciones Linux
2. **Automatización de backups**: Crear un sistema para respaldar configuraciones
3. **Gestión de entornos**: Ampliar soporte para otros gestores de paquetes (conda, pipx)
4. **Personalización por proyecto**: Perfiles específicos según el directorio actual
5. **Integraciones con APIs**: Widgets para información de clima, tareas, calendario

He creado este tutorial como parte de mi serie sobre configuraciones personales. Si te ha resultado útil, considera revisar los otros tutoriales de la serie:

1. [HDA-NAS](https://github.com/backmind/tutorials/blob/main/hda-nas.md): Configuración de hardware para NAS
2. [HDA-SERV](https://github.com/backmind/tutorials/blob/main/hda-serv.md): Configuración del sistema servidor
3. **HDA-TERM** (este tutorial): Configuración de terminal y PowerShell
4. HDA-SVC (en desarrollo): La capa de aplicación donde el valor práctico se materializa a través de múltiples servicios especializados.

Estoy abierto a sugerencias, recomendaciones y mejoras para esta guía. Si tienes alguna idea o encuentras algún error, no dudes en comentarlo o hacer un [PR](https://github.com/backmind/tutorials) en el repositorio.

---

![](https://github.com/backmind/tutorials/blob/main/hda-term-assets/x2OCV3r.png)

Esta obra está bajo una licencia Reconocimiento-No comercial 4.0 de Creative Commons. Para ver una copia de esta licencia, visite https://creativecommons.org/licenses/by-nc/4.0/deed.es o envíe una carta a Creative Commons, 171 Second Street, Suite 300, San Francisco, California 94105, USA.
