![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/yV7A3LJ.jpeg)
[← HDA-NAS](https://github.com/backmind/tutorials/hda-nas.md) **|** [↑ HDA-SERV](#indice) **|** [HDA-DOCKER →](/dev/null)

Buenas de nuevo, queridos mediavidensis,

Allá en febrero del 22 [monté un hilo](https://www.mediavida.com/foro/hard-soft/hda-nas-hardware-684087) sobre la adquisición de un NAS para backup en casa. En aquel hilo caminé pormenorizadamente por el concepto de NAS, la selección del mismo, el hardware, y los discos duros. Terminaba aquel hilo indicando que sería el primero en una serie de tres: 1) [Hardware](https://www.mediavida.com/foro/hard-soft/hda-nas-hardware-684087), 2) [Configuración](https://www.mediavida.com/foro/hard-soft/hda-serv-configuracion-705890 del sistema), y 3) [Microservicios](dev/null). Pues bien, este que tenéis delante es el segundo hilo de la saga, el de la configuración del sistema. 

La razón de la existencia de este hilo es que conforme iba instalando todo, también iba documentándolo. Así que mi propósito es adaptar un poco las notas que he ido tomando para compartirlas con vosotros. Seguro que muchos podrán aportar y recomendar diferentes cosas, ¡y agradecido de antemano quedo! He intentado mantener hipervínculos a las fuentes que he ido recorriendo, de tal guisa que no entro en la explicación de cada uno de los pasos a bajo nivel. Si queréis saber más sobre algo específico podéis acceder al hipervínculo asociado. Por último, esta instalación está hecha para mi caso de uso, mis necesidades y mi entorno. Lo bueno de los sistemas \*nix es que son harto configurables, por lo que cada uno puede encontrar la solución que más se le ajuste y le guste.

# Nota
Antes de continuar, tal como hice en el anterior hilo, debo comentar que no soy ningún experto a bajo nivel en la materia. Tengo nociones de linux porque hace tiempo que juego con él (de ahí mi nick), pero no soy profesional de sistemas o redes ni de coña. Mi trasfondo es de programador y de físico, pero siempre he sido entusiasta de la informática y desde pequeño me he dedicado a montar, desmontar y formatear mis ordenadores. Sin embargo, la parte del entendimiento tecnológico fundamental le corresponde a un ingeniero informático reglado, para mí todo esto es solo entretenimiento.

Varios de los pasos que comentaré en este y los otros hilos de la serie requieren de conocimientos de hardware, de administración de sistemas, de securización y de backend. Soy un novato en el asunto pero me gusta aprehender. *Lo que quiero decir con esto es que lo que comparto puede estar errado*. Por favor, si encontráis algún error de contenido o forma, hacédmelo saber. Este hilo es solo una guía de instalación y configuración de un ordenador con el objetivo de ser un homelab/servidor casero.

Algunas partes de la configuración son extensas. Además, como esta configuración es integral, no me voy a detener en qué es cada una de las cosas que instalo/configuro. Si tenéis alguna duda respecto a algún paquete, servicio, configuración o plugin, simplemente preguntad en este hilo o buscar en la red para qué sirve.

<a name="indice"></a>
# 1. - Índice
1. [Índice](#indice)
2. [Preámbulo](#preambulo)
2.1 [Motivación](#motivacion)
2.2 [¿Qué es un homelab?, ¿por qué un homelab?](#homelab)
2.3 [Hardware](#hardware)
3. [Primeros pasos](#primerospasos)
3.1 [Sources list](#sources)
3.2 [Sudo](#sudo)
3.3 [SSH config](#ssh)
3.4 [Firewall](#firewall)
3.5 [Wake on lan](#wol)
3.6 [Restos de la configuración básica](#basica)
4. [Macroconfiguración de zsh](#zsh)
4.1 [Instalando el core](#zshcore)
4.2 [oh-my-zsh plugins](#zshplugins)
4.3 [Configurando .zshrc](#zshrc)
5. [Instalando CUDA drivers](#cuda)
6. [Instalando zfs](#zfs)
6.1 [Crear un pool de cero](#pool)
6.2 [Montar un volumen](#volumen)
7. [Samba](#samba)
7.1 [Configurando las opciones globales de Samba](#sambacfg)
7.2 [Creando directorios compartidos de Samba](#sambadir)
7.3 [Creando Samba Share User y grupo](#sambausr)
8. [Docker](#docker)
8.1 [Instalación de Docker](#dockerinst)
8.2 [Docker rootless mode](#dockerrootless)
8.3 [Nvidia docker toolkit](#dockernvidia)
9. [Servidor DNS Pi-Hole](#pihole)
10. [Palabras finales](#final)
10.1 [Para el futuro](#futuro)
10.2. [¡Continúa con la serie!](#continua)

<a name="preambulo"></a>
# 2. - Preámbulo [↑](#indice)
<a name="motivacion"></a>
### 2.1. - Motivación [↑](#indice)

Tras casi dos años usando el NAS de synology ([hda-nas](https://github.com/backmind/tutorials/hda-nas.md)) se me ha quedado muy, muy corto). La razón es que empecé a exigirle bastante. Más allá de salirme de la caja de [DSM](https://www.synology.com/en-global/dsm/7.1/software_spec/dsm) (el OS privativo de synology) para configurar a mi gusto muchas cosas de \*nix, resulta que le estaba exigiendo demasiado al pobre ordenador. En los últimos años me he convertido en un gran aficionado de [docker](https://learn.microsoft.com/es-es/dotnet/architecture/microservices/container-docker-introduction/docker-defined), y el [ds920+](https://global.synologydownload.com/download/Document/Hardware/DataSheet/DiskStation/20-year/DS920+/spn/Synology_DS920_Plus_Data_Sheet_spn.pdf) simplemente no podía con los microservicios que yo le estaba exigiendo o quería exigirle.

Recientemente, he adquirido un nuevo ordenador para el trabajo, así que mi ordenador antiguo ha quedado libre de pecado. Por tanto, era un perfecto momento de reaprovecharlo un poco, transformándolo en mi homelab, y así trastear, montar microservicios y demás tonterías. Es decir, el segundo de esta trilogía de hilos no va sobre la configuración de un sistema DSM sino sobre la instalación y puesta a punto de un homelab casero. Usaré la última versión de Debian, [Debian 12](https://www.debian.org/News/2023/20230610), sin interfaz gráfica (sin X11). En el tercer hilo hablaré sobre los microservicios que lanzo, dando justificación al hardware.

<a name="homelab"></a>
### 2.2. - ¿Qué es un homelab?, ¿por qué un homelab? [↑](#indice)
Lo primero que debemos preguntarnos es ¿qué es un homelab y por qué debería interesarnos?  Un homelab representa un espacio de laboratorio informático montado en casa, diseñado para experimentar con nuevas tecnologías y adquirir conocimientos sobre redes y gestión de sistemas. Algunas razones para montar de un homelab podrían ser:

- Exploración de nuevas tecnologías: El homelab ofrece una vía excelente para adentrarse y poner a prueba distintas tecnologías en un entorno seguro. Esto implica la instalación de diversos sistemas operativos, experimentación con diversos servicios y el aprendizaje en la configuración y administración de distintos tipos de hardware.

- Desarrollo de habilidades en gestión de sistemas: En un homelab puedes fortalecer y expandir tus habilidades en la gestión de sistemas. Aquí se pueden adquirir conocimientos en la configuración y administración de servidores, redes, almacenamiento y otros sistemas informáticos.

- Economía: Mediante un homelab puedes, aprovechando el hardware que ya tengas por casa, montarte tu juguete que puede servir como alternativa para reducir costes asociados a servicios en la nube. Como instalamos y gestionamos nuestros propios servidores y servicios podemos acceder a ellos sin depender de plataformas externas.

<a name="hardware"></a>
### 2.3. - Hardware [↑](#indice)
Lo que haré será reaprovechar mi ordenador antiguo intentando gastar poco en su puesta a punto. Empecé haciendo una limpieza integral de la caja. Cambié dos de los ventiladores antiguos que tras casi siete años ya traqueteaban un poco. También cambié la pasta térmica del procesador. De pura suerte, tras hacer esto, la [AIO del CPU](https://nzxt.com/en-ES/product/kraken-x63) murió, así que compré un disipador bien valorado actualmente ([Thermalright Assasin 120E](https://www.thermalright.com/product/peerless-assassin-120-se-argb/)) y sustituí la AIO estropeada. También adquirí dos discos duros [EXOS x18 Enterprise](https://www.seagate.com/es/es/products/enterprise-drives/exos-x/x18/) de 18 Tb. Lo último que compré fue una tarjeta de red de 10 Gb [TP-Link TX401](https://www.tp-link.com/es/home-networking/adapter/tx401/). 

A continuación listaré pero no entraré en las especificaciones técnicas del hardware final, como sí hiciera [en el hilo anterior](https://github.com/backmind/tutorials/hda-nas.md#hardware).

#### Especificaciones técnicas
OS: [Debian 12](https://www.debian.org/)
CPU: [Intel i7 7700 k](https://www.intel.com/content/www/us/en/products/sku/97129/intel-core-i77700k-processor-8m-cache-up-to-4-50-ghz/specifications.html)
GPU: [Gigabyte AORUS GeForce RTX 3080 MASTER (Rev.1.0) 10GB GDDR6](https://www.gigabyte.com/es/Graphics-Card/GV-N3080AORUS-M-10GD-rev-10#kf)
MOBO: [Asus ROG STRIX Z270E GAMING](https://rog.asus.com/motherboards/rog-strix/rog-strix-z270e-gaming-model/)
PSU: [Corsair RMX750 80 Plus Gold 750W](https://www.corsair.com/eu/es/p/psu/cp-9020179-eu/rmx-series-rm750x-750-watt-80-plus-gold-certified-fully-modular-psu-eu-cp-9020179-eu)
RAM: 4 × 8 Gb (32 Gb) [KFA2 HOF Hall Of Fame 3600MHz (PC4-28800) CL17](https://www.profesionalreview.com/2016/12/02/kfa2-hof-ddr4-review/)
HDD M.2: 2 × 1000 Gb (2 Tb) [Samsung SSD 970 EVO Plus](https://www.samsung.com/es/memory-storage/nvme-ssd/970-evo-plus-1tb-mz-v7s1t0bw/) + [Crucial CT1000P1SSD8](https://content.crucial.com/content/dam/crucial/ssd-products/p1/flyer/crucial-p1-nvme-m2-ssd-productflyer.pdf)
\* HDD SATA: 2 × 18 Tb (36 Tb) [EXOS x18 Enterprise](https://www.seagate.com/es/es/products/enterprise-drives/exos-x/x18/)
\* NIC:  1 × [TP-Link TX401) (10 Gb RJ45](https://www.tp-link.com/es/home-networking/adapter/tx401/)

\* Quitando los ventiladores y el disipador, por manteminiento, esto es lo único que he comprado para metamorfosear mi antigua battlestation en un servidor.
<a name="sobrered"></a>
#### Sobre la red
Recientemente, he actualizado mi LAN y mi WAN a 10 Gb, razón por la que le he metido este NIC al servidor. Mi PC de trabajo va con un [NIC 10G integrado](https://www.asus.com/motherboards-components/motherboards/proart/proart-x670e-creator-wifi/), y al NAS le puse un NIC de 5 Gb por usb 3.0 ([QNAP QNA-UC5G1T](https://www.qnap.com/en/product/qna-uc5g1t)). Estos dispositivos van a un HUB tonto de 10G ([TL-X105](https://www.tp-link.com/es/business-networking/unmanaged-switch/tl-sx105/)), que conecta al único puerto 10G que monta el router ([ZTE F8648P](https://www.zte.com.cn/global/product_index/smart_home_en/ont/zxhn-f8648p0/zxhn-f8648p.html)) de mi ISP (DIGI). Como varios de los servicios que pretendo consumen ancho de banda, para mí era relevante actualizar la LAN y la WAN. Mi intención es que el servidor gestione todas las conexiones de mis dispositivos a través de [openVPN](https://openvpn.net/). Es decir, toda navegación, desde los vídeos en los móviles hasta las películas en netflix 4k, sin olvidar los [backups](https://www.synology.com/en-global/dsm/feature/active-backup-business/pc diarios hacia el NAS), pasarán por el servidor, pudiendo haber concurrencia. También es importante para temas de torrent/seedbox, así como para [Plex](https://www.plex.tv/personal-media-server/ )y algún servidor de juegos que pretendo. 

<a name="primerospasos"></a>
# 3. - Primeros pasos [↑](#indice)
Esta guía parte de una [instalación fresca de Debian 12](https://www.debian.org/CD/http-ftp/#stable). Para ello, se ha montado un pendrive y se ha hecho una instalación regular sin marcar el entorno gráfico en la instalación. Este ha sido el único momento en el que conectaremos un teclado y una pantalla al ordenador. A partir de aquí, todo el servidor será manejado en entorno consola mediante una conexión [SSH](https://www.openssh.com) (configurada durante la instalación).

Así que nos conectamos al servidor mediante ssh y... ¡empezamos!:

<a name="sources"></a>
## 3.1. - Sources list [↑](#indice)
Como hemos instalado Debian 12 desde usb debemos comentar la línea en [sources list](https://wiki.debian.org/SourcesList) pues, si no, tendremos error con el apt dado que intentará acceder al usb cada vez. Así que, como root:
```bash
nano /etc/apt/sources.list
```
Comentamos las líneas referentes al cdrom (la "#" antes de la línea)
```shell
#deb cdrom:[Debian GNU/Linux 12.2.0 _Bookworm_ - Official amd64 DVD Binary-1 with firmware 20231007-10:29]/ bookworm main non-free-firmware
```
<a name="sudo"></a>
## 3.2. - Sudo [↑](#indice)
Para mayor comodidad instalaremos "sudo", de modo que podamos ejecutar comandos de root desde nuestro usuario, previa identificación. Actualizamos apt-get e instalamos sudo
```shell
sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y
apt-get install sudo
```
Con esto lo tenemos instalado, solo falta que añadamos nuestro usuario a sudoers (mi usuario es "hda", cámbialo por el tuyo):
```shell
usermod -aG sudo hda
```
<a name="ssh"></a>
## 3.3. - SSH Config [↑](#indice)
### 3.3.1. - Keys
Procedemos [configurando el ssh](https://www.digitalocean.com/community/tutorials/how-to-configure-ssh-key-based-authentication-on-a-linux-server) para loguear con ssh key y no con contraseña. Esto hace la autentificación más segura y sencilla.
1. Creamos (si no tenemos ya) la clave en el ordenador local: [ssh-keygen](https://www.ssh.com/academy/ssh/keygen#what-is-ssh-keygen?)
2. Copiamos nuestra clave pública en el servidor
##### Desde Linux al Servidor
```Shell
ssh-copy-id hda@HDA-SERV
```
##### Desde Windows al Servidor
```Shell
# primero creamos al carpeta .ssh/ en nuestra home del servidor
mkdir ~/hda/.ssh

# luego en consola de windows desde la carpeta ssh donde creamos previamente las claves, la copiamos al servidor:
scp id_ed25519.pub hda@HDA-SERV:/home/hda/.ssh/authorized_keys
```
#### Configuración de permisos
Aplicamos los permisos correctos a nuestra carpeta .ssh
```Shell
chmod 700 /home/hda/.ssh && chmod 600 /home/hda/.ssh/authorized_keys
chown -R hda:hda /home/hda/.ssh
```
### 3.3.2. - [opcional] Configuración SSH
Ahora configuraremos el servidor SSH a nuestro gusto, partiendo del siguiente archivo podemos cambiar varias cosas:
```Shell
sudo nano /etc/ssh/sshd_config
```
Podemos cambiar las siguientes cosas:
```Shell
Port 4444 #Cambio de puerto SSH
PasswordAuthentication no #Deshabilitar el login por contraseña
PermitRootLogin no #Deshabilitar el Root login
```
Por último reiniciamos el servicio:
```Shell
sudo systemctl restart ssh
```
Y con esto tenemos el ssh configurado por completo.
<a name="firewall"></a>
## 3.4. - Firewall[↑](#indice)
El siguiente paso será instalar un firewall en el sistema. Usaremos [Uncomplicated Firewall](https://help.ubuntu.com/community/UFW). Y lo configuraremos de tal modo que por defecto prohiba toda conexión entrante, pero permita la saliente. Además, añadiremos la regla para que acepte conexiones ssh (del paso anterior). Todo esto es fácil con los siguientes pasos:
```Shell
sudo apt-get -y install ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 4444 #Add rules on ssh port
sudo ufw enable
sudo reboot
```
<a name="wol"></a>
## 3.5. - Wake on Lan [↑](#indice)
¡Es importante que el servidor se pueda levantar mediante [Wake on Lan](https://www.redeszone.net/tutoriales/redes-cable/que-es-wake-on-lan/)! Si por alguna razón se encuentra en estado apagado (Estado S5), necesitamos poder encenderlo remotamente. Para ello, la tarjeta de red debe [ser compatible](https://wiki.debian.org/WakeOnLan#Checking_WOL) (la g en la siguiente imagen):
```Shell
sudo apt-get -y install ethtool
ip link show # listamos los interfaces
sudo ethtool enp3s0 #chequeamos el interfaz objetivo
```
<a name="imagen1"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/Ddqqv3d.png)
*Imagen 1. Captura de pantalla con la información WOL del NIC.*
En el caso de que lo sea, [lo activamos con](https://wiki.debian.org/WakeOnLan#Enabling_WOL):
```Shell
sudo ethtool -s enp3s0 wol g
sudo reboot
```
<a name="basica"></a>
## 3.6. - Restos de la configuración básica[↑](#indice)
Aprovechando [este enlace](https://www.snel.com/support/initial-server-setup-with-debian-10/) y el feedback del compañero @carracho vamos a configurar un par de cosas más
### Unatended upgrades
El propósito de [UnattendedUpgrades](https://wiki.debian.org/UnattendedUpgrades) es mantener la máquina con los últimos updates de seguridad, así que se lo metemos al servidor y lo configuramos.
```bash
sudo apt-get -y install unattended-upgrades apt-listchanges
sudo dpkg-reconfigure -plow unattended-upgrades
```
### Timezone
Podemos listar los timezones mediante:
```Shell
timedatectl list-timezones
```
y a continuación establecemos el que deseemos:
```Shell
sudo timedatectl set-timezone Europe/Madrid
```
### Network Time Protocol
Ahora instalamos ntp, Network Time Protocol, sirve para sincronizar el reloj del ordenador con servidores de sincronización. Hacer esto es una buena práctrica para mantener los logs del servidor ajustados.
```bash
apt-get -y install ntp
sudo /etc/init.d/ntpsec start
```
Con esto ya tenemos configurado el tiempo del ordenador.
### Set Hostname
Ponerle nombre a la máquina. Podemos ponerle un FQDN o un identificador, lo que más nos convenga
```Shell
sudo hostnamectl set-hostname HDA-SERV
```
Podemos editar hosts para añadir este nombre:
```Shell
sudo nano /etc/hosts
```
Y añadimos la línea
```Shell
127.0.0.1    localhost HDA-SERV
```
Este paso de hosts, relacionando la IP del servidor con un nombre, habría que repetirlo en los ordenadores de la lan para que el servidor sea reconocible por nombre (y no necesariamente por IP). Otra opción es configurarlo en el router si vas con DHCP. Existen [varias alternativas](https://unix.stackexchange.com/a/16901) para conseguir esto.

### Reducir GRUB timeout
El [GRUB](https://www.gnu.org/software/grub/) es programa que carga el kernel del OS elegido. Una cosilla sencilla que podemos hacer para que el boot sea más rápido es cambiar el timeout del GRUB a uno más corto. Editamos ese tiempo en el siguiente archivo:
```Shell
sudo nano /etc/default/grub
```
y después lo actualizamos:
```Shell
sudo update-grub
```
### Tuneamos neofetch
Entre los varios paquetes que hemos instalado previamente, uno de ellos fue [neofetch](https://github.com/dylanaraps/neofetch). Este es un programa que nos da la info del sistema. En esta configuración esta info la dará automáticamente al loguear por ssh. Para adaptar neofetch al gusto editamos el archivo:
```bash 
nano ~/.config/neofetch/config.conf
```
y, para mi gusto, añadimos:
```bash
print_info() {
    info title
    info underline

    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "Resolution" resolution
    info "DE" de
    info "WM" wm
    info "WM Theme" wm_theme
    info "Theme" theme
    info "Icons" icons
    info "Terminal" term
    info "Terminal Font" term_font
    info "CPU" cpu
    info "CPU Usage" cpu_usage
    info "GPU" gpu
    info "GPU Driver" gpu_driver  # Linux/macOS only
    info "Memory" memory
    info "Disk" disk
    # info "Battery" battery
    # info "Font" font
    # info "Song" song
    # [[ "$player" ]] && prin "Music Player" "$player"
    # info "Local IP" local_ip
    # info "Public IP" public_ip
    # info "Users" users
    # info "Locale" locale  # This only works on glibc systems.

    info cols
}
```

También cambiamos la siguiente línea de modo que de la temperatura en centígrados:
```bash
cpu_temp="C"
```
### Activamos logrotate
Mediante logrotate tendremos mejores logs para las aplicaciones que gustemos. Dejamos en avance configurado logrotate para traefik, contenedor que veremos en el siguiente hilo de la serie. Para ello creamos el siguiente archivo:
```bash
sudo nano /etc/logrotate.d/traefik
```
y lo llenamos con
```bash
/opt/traefik/logs/*.log {
  daily
  rotate 30
  missingok
  notifempty
  compress
  dateext
  dateformat .%Y-%m-%d
  create 0644 root root
  postrotate
  docker kill --signal="USR1" $(docker ps | grep '\btraefik\b' | awk '{print $1}')
  endscript
}
```
Nota: el contenedor ha de llamarse *traefik* y deberá tener montado este volumen:
```bash
volumes:
  - /opt/traefik/logs:/logs
```
<a name="zsh"></a>
# 4. - Macroconfiguración de zsh [↑](#indice)
<a name="zshcore"></a>
## 4.1. - Instalando el core [↑](#indice)
Ahora instalaremos una shell hipervitaminada a nuestro usuario. En concreto [zsh](https://www.zsh.org/)+[ohmyzsh](https://ohmyz.sh/)+[powerlevel](https://github.com/romkatv/powerlevel10k). Lo haremos bastante del tirón. Hemos de tener en cuenta que la siguiente configuración es la que a mí me gusta, para otros podría ser diferente.

```Shell
sudo apt-get -y install zsh git fonts-powerline eza fzf neofetch bat
sh -c "$(wget -O- https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```
Reiniciamos la consola, debería cargarnos directamente zsh. Ahí podremos instalar powerlevel 10k:
```Shell
git clone https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
```
En el *.zshrc* cambiamos el *ZSH_THEME* a *p10k*:
```Shell
#ZSH_THEME="robbyrussell" #comentamos el theme anterior
ZSH_THEME="powerlevel10k/powerlevel10k" #e indicamos el p10k theme
```
Reiniciamos la consola y procedemos con la configuración de powerlevel.
<a name="zshplugins"></a>
## 4.2. - oh-my-zsh plugins [↑](#indice)
Reentramos en la consola y debería cargarnos directamente zsh. Lo siguiente será descargar los plugins de oh-my-zsh que nos interesen. La siguiente es una colección con los instaladores de plugins que yo uso. Plugins oh-my-zsh:
```Shell
#fast-syntax-highlighting
git clone https://github.com/zdharma-continuum/fast-syntax-highlighting.git \
  ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/fast-syntax-highlighting
#fzf-zsh-plugin
git clone --depth 1 https://github.com/unixorn/fzf-zsh-plugin.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-zsh-plugin
#zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
#zsh-completions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions
  fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
#zsh-fzf-history-search
git clone https://github.com/joshskidmore/zsh-fzf-history-search ${ZSH_CUSTOM:=~/.oh-my-zsh/custom}/plugins/zsh-fzf-history-search
#zsh-history-substring-search
git clone https://github.com/zsh-users/zsh-history-substring-search ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-history-substring-search
#zsh-shift-select
git clone https://github.com/jirutka/zsh-shift-select.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-shift-select
#zsh-you-should-use
git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use
```

<a name="zshrc"></a>
## 4.3. - Configurando .zshrc [↑](#indice)
Lo siguiente que toca es poner al gusto la zsh, para ello editamos el archivo mediante:
```Shell
nano .zshrc
```
### 4.3.1. - Preámbulos
Añadimos a la parte superior del archivo todo lo siguiente:
```Shell
neofetch

# AUTOCOMPLETION

# initialize autocompletion
autoload -U compinit && compinit

# history setup
setopt SHARE_HISTORY
HISTFILE=$HOME/.zhistory
SAVEHIST=3000
HISTSIZE=2999
setopt HIST_EXPIRE_DUPS_FIRST
```
Podemos cambiar la forma en la que se nos presentan las fechas cambiando la siguiente línea:
```Shell
HIST_STAMPS="dd/mm/yyyy"
```
### 4.3.2. - Activamos los plugins
En la parte de plugins activamos los que hayamos descargado, para ello ponemos:
```Shell
plugins=(
        fast-syntax-highlighting
        git
        alias-finder
        zsh-autosuggestions
        zsh-completions
        zsh-fzf-history-search
        zsh-history-substring-search
        zsh-shift-select
        you-should-use
)
```
Añadimos la siguiente línea encima de "source $ZSH/oh-my-zsh.sh"
```Shell
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src
```
### 4.3.3. - Añadimos los alias y ending
Los alias son atajos de consola que simplifican mucho la vida. Yo uso unos cuantos, además de que he fusilado muchos para el futuro manejo de docker. Para añadir los alias, en el *.zshrc*, bajo "Example aliases" ponemos lo siguiente:
```Shell
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

#batcat to bat
alias bat='batcat'

# general use
alias ls='eza --icons'                                                         # ls
alias l='eza -lbF --icons --git'                                               # list, size, type, git
alias ll='eza -lbGF --icons --git'                                             # long list
alias llm='eza -lbGd --icons --git --sort=modified'                            # long list, modified date sort
alias la='eza -lbhHigUmuSa --icons --time-style=long-iso --git --color-scale'  # all list
alias lx='eza -lbhHigUmuSa@ --icons --time-style=long-iso --git --color-scale' # all + extended list

# specialty views
alias lS='eza -1 --icons'                                                       # one column, just names
alias lt='eza --tree --icons --level=2'                                         # tree
# set Safetynets
alias sudo='sudo '    # This allows sudo to run aliases
alias chmod='chmod --preserve-root'
alias chown='chown --preserve-root'
alias chgrp='chgrp --preserve-root'

# update stuff
alias aptup='sudo apt update -y && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean -y && sudo apt autoclean -y && pihole -up'

# navigation
alias prog='cd /SERV-PROG/'
alias data='cd /SERV-DATA/'

############################################################################
#                                                                          #
#               ------- Useful Docker Aliases --------                     #
#                                                                          #
#     # Installation :                                                     #
#     copy/paste these lines into your .bashrc or .zshrc file or just      #
#     type the following in your current shell to try it out:              #
#     wget -O - https://gist.githubusercontent.com/jgrodziski/9ed4a17709baad10dbcd4530b60dfcbb/raw/d84ef1741c59e7ab07fb055a70df1830584c6c18/docker-aliases.sh | bash
#                                                                          #
#     # Usage:                                                             #
#     daws <svc> <cmd> <opts> : aws cli in docker with <svc> <cmd> <opts>  #
#     dbash <container>: run a bash shell into a given container         #
#     dc             : docker compose                                      #
#     dcu            : docker compose up -d                                #
#     dcd            : docker compose down                                 #
#     dcr            : docker compose run                                  #
#     dex <container>: execute a bash shell inside the RUNNING <container> #
#     dsh <container>: run a sh shell into a given container               #
#     di <container> : docker inspect <container>                          #
#     dim            : docker images                                       #
#     dip            : IP addresses of all running containers              #
#     dl <container> : docker logs -f <container>                          #
#     dnames         : names of all running containers                     #
#     dps            : docker ps                                           #
#     dpsa           : docker ps -a                                        #
#     drmc           : remove all exited containers                        #
#     drmid          : remove all dangling images                          #
#     drun <image>   : execute a bash shell in NEW container from <image>  #
#     dsr <container>: stop then remove <container>                        #
#                                                                          #
############################################################################
function dbash-fn {
    docker exec -it $(docker ps -aqf "name=$1") bash;
}

function dsh-fn {
    docker exec -it $(docker ps -aqf "name=$1") sh;
}

function dnames-fn {
	for ID in `docker ps | awk '{print $1}' | grep -v 'CONTAINER'`
	do
    	docker inspect $ID | grep Name | head -1 | awk '{print $2}' | sed 's/,//g' | sed 's%/%%g' | sed 's/"//g'
	done
}

function dip-fn {
    echo "IP addresses of all named running containers"

    for DOC in `dnames-fn`
    do
        IP=`docker inspect --format='{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}' "$DOC"`
        OUT+=$DOC'\t'$IP'\n'
    done
    echo -e $OUT | column -t
    unset OUT
}

function dex-fn {
	docker exec -it $1 ${2:-bash}
}

function di-fn {
	docker inspect $1
}

function dl-fn {
	docker logs -f $1
}

function drun-fn {
	docker run -it $1 $2
}

function dcr-fn {
	docker compose run $@
}

function dsr-fn {
	docker stop $1;docker rm $1
}

function drmc-fn {
       docker rm $(docker ps --all -q -f status=exited)
}

function drmid-fn {
       imgs=$(docker images -q -f dangling=true)
       [ ! -z "$imgs" ] && docker rmi "$imgs" || echo "no dangling images."
}

# in order to do things like dex $(dlab label) sh
function dlab {
       docker ps --filter="label=$1" --format="{{.ID}}"
}

function dc-fn {
        docker compose $*
}

function d-aws-cli-fn {
    docker run \
           -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
           -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
           -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
           amazon/aws-cli:latest $1 $2 $3
}

alias daws=d-aws-cli-fn
alias dbash=dbash-fn
alias dc=dc-fn
alias dcu="docker compose up -d"
alias dcd="docker compose down"
alias dcr=dcr-fn
alias dex=dex-fn
alias dsh=dsh-fn
alias di=di-fn
alias dim="docker images"
alias dip=dip-fn
alias dl=dl-fn
alias dnames=dnames-fn
alias dps="docker ps"
alias dpsa="docker ps -a"
alias drmc=drmc-fn
alias drmid=drmid-fn
alias drun=drun-fn
alias dsp="docker system prune --all"
alias dsr=dsr-fn# docker bindkeys

# autocompletion using arrow keys (based on history)
bindkey '\e[A' history-search-backward
bindkey '\e[B' history-search-forward

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#nvidia cuda stuff
export LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/cuda/lib64
```

Con el alias aptup pondrás al día el apt, descuida por el error de pihole, que instalaremos más adelante. Además de los alias también incluye control para poder seleccionar y navegar con el teclado entre palabras más fácilmente, además de información sobre nvidia CUDA necesaria para el siguiente paso.
<a name="cuda"></a>
# 5. - Instalando CUDA drivers [↑](#indice)
En mi caso, además de la gráfica integrada del procesador, me interesa que el sistema reconozca la GPU de nvidia con los drivers propietarios para hacer uso de [CUDA](https://developer.nvidia.com/cuda-zone). Para ello debemos instalar los [drivers de la gráfica](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#pre-installation-actions). Cabe destacar que, además de instalar los prerrequisitos y configurar los drivers, es necesario [desactivar los drivers](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#disabling-nouveau) nvidia [Nouveau](https://nouveau.freedesktop.org/), no propietarios, que integra debian por defecto.
#### Instalamos los siguientes paquetes
```Shell
sudo apt-get -y install gcc make chafa exiftool software-properties-common
```
#### Desactivamos Nouveau
Desactivar nouveau, creamos el siguiente archivo:
```Shell
sudo nano /etc/modprobe.d/blacklist-nouveau.conf
```
Y lo llenamos con:
```Shell
blacklist nouveau
options nouveau modeset=0
```
Después regeneramos el kernel initramfs y reiniciamos:
```Shell
sudo update-initramfs -u
sudo apt-get install linux-headers-$(uname -r)
sudo add-apt-repository contrib
sudo apt-key del 7fa2af80
sudo reboot
```
Luego descargamos el [cuda-keyring](https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#network-repo-installation-for-debian) package, actualizamos apt, instalamos y reiniciamos:
```Shell
wget https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt-get update
sudo apt-get -y install cuda
sudo reboot
```
<a name="zfs"></a>
# 6. - Instalando zfs [↑](#indice)
Una de las cosas que me propuse con este servidor es jugar con el sistema de archivos [zfs](https://openzfs.org/wiki/Main_Page). Este es un sistema de archivos muy utilizado, tipo [BTFRS](https://github.com/backmind/tutorials/hda-nas.md#formato). En el [siguiente enlace](https://hetmanrecovery.com/es/blog/why-is-the-zfs-file-system-in-linux-ubuntu-so-good.htm) podéis leer sobre sus ventajas. En mi caso crearé dos pools de datos. 1) un único disco M.2, para aplicaciones y volúmenes de docker. 2) dos discos mecánicos de 18 Tb, en espejo; es decir, con la información redundada. 

Cabe señalar que estableceré una copia de seguridad diaria del servidor en el NAS, pero solo del disco del sistema y de 1). No copiaré 2) porque será un disco de descargas y por tanto de información transitoria que no pretendo conservar más allá de tener la redundancia en espejo que comento.

Para instalar zfs:
```Shell
sudo apt-get -y install gdisk linux-headers-amd64 zfsutils-linux zfs-dkms zfs-zed
sudo reboot
```
<a name="pool"></a>
## 6.1. - [opcional] Crear un pool de cero [↑](#indice)
Si necesitamos crear los volúmenes desde cero haremos lo siguiente
### Borrar los discos
*¡Peligro, esto te elimina completamente la información de los discos!* He puesto "DISCO1" hasta "DISCON" para que tengas que cambiarlo activamente. Ojo que perderás todo.
```Shell
sudo sgdisk --zap-all /dev/DISCO1
sudo sgdisk --zap-all /dev/DISCON
```
### Crear un volumen
Con los discos listos ya puedes crear un volumen (o pool). En la siguiente línea lo hacemos. Fíjate en el final de la línea. Al volúmen le llamaré "SERV-DATA", será una pool en espejo (básicamente una [RAID 1](https://www.mediavida.com/foro/hard-soft/hda-nas-hardware-684087#raid)) con los discos sda y sdb.
```shell
sudo zpool create -f -d -o ashift=12 -O atime=off -o feature@lz4_compress=enabled SERV-DATA mirror /dev/sda /dev/sdb
```
<a name="volumen"></a>
## 6.2. - Montar un volumen [↑](#indice)
Y por último [montamos los volúmenes](https://www.cyberciti.biz/faq/freebsd-linux-unix-zfs-automatic-mount-points-command/) que haya.
### 6.2.1. - [opcional] Buscar los pools creados
Si, independientemente de que hayas creado pools en el paso anterior, tienes pools creados previamente puedes listarlos mediante.
```Shell
sudo zpool import
```
<a name="imagen2"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/ajzh5dQ.png)
*Imagen 2. Captura de pantalla con el listado de los pools zfs del sistema.*
### 6.2.2. - Cargar los pools creados
Solo queda cargar los pools creados. Una vez sabiendo su nombre haces (en mi caso mis pools son *SERV-PROG* y *SERV-DATA*):
```
sudo zpool import -f SERV-PROG
sudo zpool import -f SERV-DATA
```
Ahora puedes ver el status:
```Shell
sudo zpool status
```
<a name="imagen3"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/EvntAzt.png)
*Imagen 3. Captura de pantalla con el estado de los pools zfs del sistema.*
<a name="samba"></a>
# 7. - Samba [↑](#indice)
Para poder comunicarnos con facilidad en el entorno de red, instalaremos y configuraremos el protocolo [samba](https://computingforgeeks.com/how-to-configure-samba-share-on-debian/):
```Shell
sudo apt-get -y install samba smbclient cifs-utils
```
<a name="sambacfg"></a>
## 7.1. - Configurando las opciones globales de samba [↑](#indice)
En el archivo
```Shell
sudo nano /etc/samba/smb.conf
```
ponemos el work group correcto (yo uso desde hace años *CLANDESTINE*)
```Shell
workgroup = CLANDESTINE
```
<a name="sambadir"></a>
## 7.2. - Creando directorios compartidos Samba [↑](#indice)
Crearemos un par de directorios, uno público y otro privado, dentro del pool de data:
```Shell
sudo mkdir /SERV-DATA/public && sudo mkdir /SERV-DATA/private
```
En el archivo
```Shell
sudo nano /etc/samba/smb.conf
```
Al final del archivo configuramos estos directorios que hemos creado
```Shell
[public]
   comment = Public Folder
   path = /SERV-DATA/public
   writable = yes
   guest ok = yes
   guest only = yes
   force create mode = 775
   force directory mode = 775
[private]
   comment = Private Folder
   path = /SERV-DATA/private
   writable = yes
   guest ok = no
   valid users = @smbshare
   force create mode = 770
   force directory mode = 770
   inherit permissions = yes
```
<a name="sambausr"></a>
## 7.3. - Creando Samba share user y grupo [↑](#indice)
Necesitamos un share user group para acceder a lo privado compartido, así que creamos el grupo y añadimos las carpetas previas a este grupo, dándoles los permisos adecuados
```Shell
sudo groupadd smbshare
sudo chgrp -R smbshare /SERV-DATA/private/
sudo chgrp -R smbshare /SERV-DATA/public/
sudo chmod 2770 /SERV-DATA/private/
sudo chmod 2775 /SERV-DATA/public/
```
Lo siguiente es crear un user local sin login para acceder a la carpeta privada y lo añadimos al grupo que creamos antes.
```Shell
sudo useradd -M -s /sbin/nologin sambauser
sudo usermod -aG smbshare sambauser
```
Ahora creamos una contraseña para el usuario y lo activamos
```Shell
sudo smbpasswd -a sambauser
sudo smbpasswd -e sambauser
```
Y, por último, añadimos la regla al firewall y reiniciamos el servicio
```Shell
sudo ufw allow from 192.168.1.0/24 to any app Samba
sudo systemctl restart nmbd
```
<a name="docker"></a>
# 8. - Docker [↑](#indice)
El último paso de esta guía es instalar [docker](https://www.docker.com/). Como podéis ver, lo que hemos recorrido hasta ahora ha sido la configuración funcional del servidor, para poder trabajar con él. Docker será nuestro gestor de servicios. Es decir, todo lo que excede los servicios que hemos ido creando hasta ahora serán instanciados mediante docker. Esta configuración de docker comprende el tercer y último hilo de esta trilogía. Por lo pronto, instalemos y configuremos docker.
<a name="dockerinst"></a>
## 8.1. - Instalación de Docker [↑](#indice)
Vamos a continuación a [instalar Docker](https://docs.docker.com/engine/install/debian/#install-using-the-repository) y [Docker-Compose](https://docs.docker.com/compose/). 
### 8.1.1. - GPG key
Lo primero que necesitamos es instalar el GPG key
```bash
# Add Docker's official GPG key:
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```
### 8.1.2. - Docker package y test
```Shell
sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```
Con esto ya debería estar funcionando, podemos hacer un test mediante la línea
```Shell
sudo docker run hello-world
```
<a name="imagen4"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/c16lU6p.png)
*Imagen 4. Captura de pantalla con la prueba de funcionamiento de docker.*
Este no es mal momento para incrementar la [memoria virtual](https://www.elastic.co/guide/en/elasticsearch/reference/current/vm-max-map-count.html) disponible para los contenedores. Para ello añadimos la línea *vm.max_map_count=262144* en */etc/sysctl.conf* y reiniciamos:
```bash
sudo echo "vm.max_map_count=262144" | sudo tee -a /etc/sysctl.conf
sudo reboot
```
<a name="dockerrootless"></a>
## 8.2. - Docker rootless mode [↑](#indice)
Uno de los objetivos de esta guía es hacer las cosas seguras (configuración de ssh, firewall, etc.). Como la mayoría de los microservicios los correremos a través de docker, y docker por defecto corre sobre root, desde hace un par de años existe la posibilidad de correr docker sin root, es decir [docker rootless mode](https://docs.docker.com/engine/security/rootless/). Esto puede complicar el funcionamiento de algunas imágenes docker, pero es mucho más seguro. Si un microservicio se ve comprometido, complica mucho al atacante la escalada de privilegios en el host.

Para proceder con docker rootles, instalamos los siguientes paquetes
```Shell
sudo apt-get install -y dbus-user-session fuse-overlayfs slirp4netns uidmap
```
Luego desactivamos el demonio de docker:
```Shell
sudo systemctl disable --now docker.service docker.socket
```

A continuación instalamos docker rootless:
```Shell
sudo apt-get install -y docker-ce-rootless-extras
/usr/bin/dockerd-rootless-setuptool.sh install
```
Una cosa interesante que podemos hacer es establecer que [la gestión de logs](https://docs.docker.com/config/containers/logging/configure/) la lleve el sistema, para ello:
```bash
mkdir ~/.config/docker && echo '{\n  "log-driver": "journald"\n}' | tee -a ~/.config/docker/daemon.json
```
Es opcional, entonces, permitir que los puertos menores a 1024 puedan ser establecidos sin privilegios:
```Bash
sudo setcap cap_net_bind_service=ep $(which rootlesskit)
systemctl --user restart docker
```
Para deshacer esto último:
```Bash
sudo setcap cap_net_bind_service=-ep $(which rootlesskit)
systemctl --user restart docker
```

¡Con esto tenemos docker corriendo rootless! Fíjate en la siguiente captura, no necesitamos "sudo" para desplegar el hello-world. Nótese que no hemos añadido el usuario a un docker group o similar (cosa que puede crear brechas de seguridad).
<a name="imagen5"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/OybY000.png)
*Imagen 5. Captura de pantalla con la prueba de funcionamiento de rootless docker.*
<a name="dockernvidia"></a>
## 8.3. - Nvidia docker toolkit [↑](#indice)
Ahora instalaremos la [caja de herramientas de nvidia](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) que permite comunicarse con docker. Configuramos el repositorio:
```bash
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list \
  && \
    sudo apt-get update
```
Y luego instalamos la herramienta
```Bash
sudo apt-get install -y nvidia-container-toolkit
```
A continuación permitimos la [ejecución rootless de nvidia](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/1.13.5/install-guide.html), configuramos el runtime y reiniciamos el servicio docker
```Bash
sudo sed -i 's/^#no-cgroups = false/no-cgroups = true/;' /etc/nvidia-container-runtime/config.toml
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```
Con esto deberíamos tener la gráfica funcionando en docker. Testea con:
```Bash
docker run --rm --gpus all debian nvidia-smi
```
<a name="imagen6"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/uLeYovr.png)
*Imagen 6. Captura de pantalla con la ejecución de nvidia-smi desde rootless docker.*
<a name="pihole"></a>
### 9. Servidor DNS Pi-Hole [↑](#indice)
Lo siguiente será instalar [Pi-Hole](https://pi-hole.net/), básicamente es un servidor DNS al que apuntarán nuestros dispositivos. De este modo podremos filtrar las peticiones a webs a nivel de red. Esto tiene efectos muy positivos, como que todas las peticiones contra la publicidad será bloqueada incluso antes de realizarse, por ejemplo

Instalar Pi-Hole es [sencillo](https://www.techaddressed.com/tutorials/installing-pi-hole-debian-ubuntu/). Pipeamos a bash el script de instalación y seguimos los pasos:
```bash
curl -sSL https://install.pi-hole.net | sudo bash
```
<a name="imagen6"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/fr2MI8x.png)
*Imagen 7. Captura de pantalla con la ejecución del instalador de pi-hole.*
Sigue los pasos de instalación al gusto y continuamos configurando. Una vez que esté instalado, lo que debemos hacer es que las DNS del servidor se apunten a sí mismo. Esto lo logramos editando el siguiente archivo:
```bash
sudo nano /etc/resolv.conf
```
Y cambiamos las ip que ahí aparecen a *127.0.0.1*
Por último, el servicio DNS corre en el puerto 53, así que lo añadimos al firewall:
```bash
sudo ufw allow 53
```
Con esto ya tienes el servidor dando la configuración básica de DNS. Si quieres hacer cosas más chulas, como reglas y grupos de reglas a según qué usuario, deberás meterte más en profundidad. [Esta](https://www.techaddressed.com/tutorials/basic-pi-hole-config/#) es una buena fuente.
<a name="final"></a>
# 10. - Palabras finales [↑](#indice)
¡Felicidades, ya tienes el servidor configurado! Muchas gracias por acompañarme hasta aquí. Tras la instalación del sistema, en este hilo hemos recorrido la configuración básica de un sistema operativo y sus dependencias para montar un homelab/servidor casero. Hemos preparado la configuración básica del sistema, luego una shell actual y cómoda, hemos instalado los drivers de nvidia para poder hacer funcionar cuda. Hemos instalado el sistema de archivos zfs y samba. Y, por último, hemos instalado docker de una forma segura. Mediante este hilo podéis seguir el discurso de pensamiento y acción que he llevado a la composición de mi homelab/servidor casero. Espero que os haya sido entretenido.
<a name="imagen7"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/4ZBIcm0.png)
*Imagen 8. Captura de pantalla con la entrada en el servidor una vez ya configurado.*
<a name="futuro"></a>
### 10.1. - Para el futuro [↑](#indice)
Ahora que ya tengo el servidor montado y estoy contento, tengo muchas ganas de hincharlo a microservicios. Lo cierto es que no pretendo hacer datahoarding y que los 18Tb en espejo debieran ser suficientes por lo pronto; pero no estaría mal proyectar cómo upgradear el juguete. Llevo ya un tiempo pensándolo y creo que mi siguiente paso sería adquirir un pequeño rack e ir montando todos los juguetes en él. Ahora el "barebone" NAS y su SAI, el SAI de mi ordenador de trabajo/servidor junto con el servidor en sí (que va en una ATX), y el hub, ocupan mucho espacio. Cuánto mejor montarlo todo ordenadito en rack, bien ventilado y con posibilidad de expandir con caddies para meter más discos duros, jeje.
<a name="continua"></a>
### 10.2. - ¡Continúa con la serie! [↑](#indice)
1. [El primer hilo](https://github.com/backmind/tutorials/hda-nas.md) trata sobre el hardware que he montado y por qué. 
2. ([este](https://github.com/backmind/tutorials/hda-serv.md)) El segundo hilo trata sobre la configuración básica del sistema. 
3. El tercer hilo sobre microservicios personales para proyectos y jugueteos que me gustaría hacer.

---

### Versión 1.1R1 (27/04/2024)

<a name="changelog"></a>
###  Changelog [↑](#indice)
- Versión 1.1R1 (27/04/2024)
 - sustituido [exa](https://github.com/ogham/exa/issues/1243) por [eza](https://github.com/eza-community/eza), tanto a la hora de instalarlo como a la hora de usarlo en los aliases de zsh.
- Versión 1.1R0 (12/12/2023)
 - Corregidas un montón de erratas
 - Añadido el comando para deshacer los privilegios para escuchar puertos bajos
 - Añadida la instalación de Network Time Protocol
 - Añadida la instalación y configuración de pi-hole
 - Añadido Unattended-Upgrades
 - Incrementada la memoria virtual de los contenedores
 - Configurado docker para usar journald system
 - Añadida una configuración de logrotate para traefik en avance
- Versión 1.0R1 (05/12/2023)
 - Corregidas un montón de erratas
 - Reformulación y explicación de parte de los procesos
- Versión 1.0R0 (04/12/2023)
 - Versión inicial.



![](https://github.com/backmind/tutorials/blob/main/hda-serv-assets/x2OCV3r.png)

Esta obra está bajo una licencia Reconocimiento-No comercial 4.0 de Creative Commons. Para ver una copia de esta licencia, visite https://creativecommons.org/licenses/by-nc/4.0/deed.es o envíe una carta a Creative Commons, 171 Second Street, Suite 300, San Francisco, California 94105, USA.