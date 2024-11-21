![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/sayIUuD.jpeg)
[↑ HDA-NAS](#indice) **|** [HDA-SERV →](https://github.com/backmind/tutorials/blob/main/hda-serv.md) **|** [HDA-DOCKER →→](/dev/null)

Buenas, queridos mediavidensis,

Desglosaré este viaje en diferentes hilos y subforos. El objetivo es dejar registrados los pasos que voy siguiendo de modo que me sirva en un futuro, pero también para que sirva como punto de interés por si otras personas se atreven a lanzarse. También es mi idea ir presentando diferentes dudas que tengo y pediros recomendaciones. Este hilo trata sobre el hardware para el NAS.

# Nota
Antes de continuar, debo comentar que no soy ningún experto a bajo nivel en la materia. Tengo nociones de cómo funcionan las cosas, pero no soy profesional de esto ni de coña. Es más, mi trasfondo es de programador y de físico, por lo que comprendo por un lado un poco sobre la lógica formal de las cosas y por otra sobre el funcionamiento tangible de los objetos. La parte del entendimiento tecnológico fundamental le corresponde a un ingeniero informático reglado, para mí todo esto solo es entretenimiento.

Varios de los pasos que comentaré en este y los otros hilos de la serie requieren de conocimientos de hardware, de administración de sistemas, de securización y de backend. Soy un novato en el asunto pero me gusta aprehender. Lo que quiero decir con esto es que lo que comparto puede estar errado. Por favor, si encontráis algún error de contenido o forma, hacédmelo saber.

<a name="indice"></a>
# 1 - Índice
1. [Índice](#indice)
2. [¿Qué es un NAS?, ¿por qué un NAS?](#nas)
3. [La motivación](#motivacion)
4. [Hardware](#hardware)
    1. [Algunas consideraciones](#consideraciones)
3. [Discos Duros](#hdd)
    1. [El tamaño](#tamanio)
    2. [El modelo](#modelo)
    3. [El formato](#formato)
    4. [La RAID](#raid)
    5. [SHR](#shr)
4. [Instalación del NAS](#instalacion)
    1. [Chequeo de los discos duros: 1º FASE](#instalacionhdd1)
    2. [Chequeo de los discos duros: 2º y 3º FASE](#instalacionhdd2)
    3. [Instalación de la ampliación de RAM](#instalacionram)
    4. [Instalación del M.2 SSD Caché](#instalacionm2)
5. [Palabras finales](#final)
    1. [Para el futuro](#futuro)
    2. [¡Continúa con la serie!](#continua)

<a name="nas"></a>
# 2 - ¿Qué es un NAS?, ¿por qué un NAS?

La palabra **NAS** viene de ***N**etwork **A**ttached **S**torage*, es decir, espacio [de datos] conectado por red. En principio los NAS están ideados como servidores de datos de carácter general. En entornos caseros se usan mucho como servidores multimedia aunque también como lugares donde salvaguardar datos. Tal es mi objetivo primordial: tener absolutamente toda mi unidad de datos reflejada en el NAS, además de crearme mi propia nube privada. Adicionalmente, me interesa disponer de una unidad de red entre todos mis dispositivos. Por último, lo utilizaré para proyectos personales como servidor personal y para jugar con Docker. 

Mi propósito es el de montar un lugar seguro para mis datos a medio y largo plazo. A este respecto las nubes propietarias pueden ser complementarias pero insuficientes: aunque hay compañías que lo ofrecen, lo habitual no es tener nubes de varios Tb de datos a nivel usuario. He barajado la idea de [backblaze.com](https://www.backblaze.com/), que ofrece estas características y un cifrado punto a punto por un precio asequible, no lo descarto, pero prefiero tener el control físico sobre mis datos. Lo ideal es seguir el precepto conocido como 3, 2, 1: tener tres copias de los datos, dos en un mismo sitio físico (ordenador+NAS) y una en otro lugar (segundo NAS, por ejemplo). De este modo, en el hipotético, remoto caso de que mi casa saliese ardiendo y por ende y por desgracia perdiese mi PC y mi NAS, seguiría teniendo una copia en algún otro lado. Por lo pronto, en lo que respecta a esta serie de hilos, montaré solo este primer NAS.
<a name="motivacion"></a>
# 3 - La motivación
Hace un mes tuve la desgracia de **perder 5.5 Tb de datos**. Por suerte conservo en copias de seguridad un 95% de los más sensibles e importantes, tales como mi tesis doctoral, los cursos de la carrera, mis libros terminados y en proceso, varios proyectos de código, etc. Sin embargo, he perdido todo lo "no importante", que ha sido mucho. Ahora que está perdido uno piensa y evalúa aquello que considera "importante". 

Por ejemplo, he perdido todos los programas de Podcast que hice allá en 2007 para la escena española del Counter Strike Source del momento, así como todas las fotografías de los torneos en los que he competido. Además, he perdido todo el *vault* de las fotografías hechas con mi cámara digital, audios del 2002, archivos que venían del 486 de mi niñez, toda la carpeta del FP de DAI (2007-09), y un muy largo etcétera. Lo dicho, al desvanecerse todo esto uno evalúa de otro modo qué considera como "datos importantes". Solo me consuela el pensar que no tardaré en olvidarme de lo desaparecido.

Cabe resaltar que en 2008 tuve una pérdida similar de 400 Gb (que al cambio serían los 5.5 Tb de hoy, supongo). La historia de esta pérdida, que ya no siento tan profundamente gracias a mi memoria, tiene su "gracia": Un compañero de clan del Counter Strike, @chunite, me vendió por unos 80€ su antiguo ordenador, pero sin caja. Para mí fue un alivio enorme pasar de los 6-8 FPS de agua en de_aztec a casi 40. Como estaba sin caja, yo tenía este ordenador dispuesto sobre la mesa y lo encendía haciendo corto con un desatornillador.
<a name="imagen1"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/95CVlFm.jpeg)

*Imagen 1. Precario ordenador personal que en 2008 llevo a una gran pérdida de datos.*

El PC montaba una controladora IDE-PCI (tal como se aprecia en la  [Imagen 1](#imagen)) con varios discos duros apilados unos sobre otros. La razón de la existencia de tanto disco duro es por haber ido a muchas *Lan parties*. Al principio íbamos con  CDs, luego con DVDs, pero finalmente lo más cómodo fueron los discos duros. Pues bien, mi queridísimo amigo @DarkKonum, quien por aquella época estaba con la carrera de informática, tuvo a bien advertirme de que no dispusiese de los discos duros de ese modo, apilados, dado que disiparían mal el calor y podría afectar a su funcionamiento.

Yo, que soy una persona sensible con mis cosas, hice buen caso de lo que me recomendaba mi amigo. Sin embargo, cierto día llegó en el que necesité montar dos discos para buscar un antivirus que me pedía un colega (no tenía claro en cuál estaba) y al montarlos me tendría que enfrentar al problema del calor. En ese momento se me encendió la bombilla: ¡si pudiese aumentar la superficie de los discos duros entonces maximizaría la transferencia de calor! (Ya apuntaba mi vocación como físico) ¿Cómo podría hacerlo? ¡Pues claro! Con papel de aluminio, que conduce fenomenal el calor (aquí apuntaba mi vocación como idiota).

Envolví los discos duros en papel de aluminio, hice el corto con el desatornillador en los pines de encendido de la placa y... sí, el papel de aluminio conduce muy bien el calor, pero también muy bien la electricidad [[4](https://es.wikipedia.org/wiki/Ley_de_la_conductividad_de_Wiedemann-Franz)]. Bravo por mí. Así perdí aquellos proverbiales 400 Gb. Menos mal que no recuerdo lo perdido. Sé que tenía capturas de pantalla del GunBound cuando en GIS era Dragón Rojo (cerca del top mundial), pero de poco más me acuerdo.


#### Nota

Durante el desarrollo de este post, aún sin terminar de montar el NAS, uno de los discos duros de 500 Gb en donde guardaba bastante copia de seguridad ha petado. ¿Cuál es la puta maldita probabilidad de que pase esto? Por el ruido es el cabezal atascado estimo que la reparación irá desde los 150€+ hasta el infinito para intentar arreglarlo. Por suerte, los datos que entrañaba no son tan valiosos como para pedir una reparación. Pero putada es.
<a name="hardware"></a>
# 4 - Hardware

Después de estar dándole vueltas al asunto con detenida calma, me he decantado por una solución propietaria. Pese a que mis capacidades técnicas me permiten montar un ordenador destinado a NAS he considerado oportuno comprar un Synology, ya no solo por la conveniencia física del aparato sino por la lógica: el software que ofrece Synology tiene muy buenas críticas. Pretendo integrarme enteramente en su ecosistema.

- NAS: Synology 920+ [[Az](https://www.amazon.es/Synology-DS920-Caja-para-bah%C3%ADas/dp/B08BG6WM3K/)][[Vendedor](https://www.synology.com/es-es/products/DS920+)]
- RAM (ampliación): Crucial 4 Gb (CT4G4SFS8266) [[Az](https://www.amazon.es/gp/product/B07HP78DZ5)][[Vendedor](https://www.crucial.com/memory/ddr4/ct4g4sfs8266)]
- SSD M.2: Samsung 960 EVO 500 Gb (MZ-V6E500) [[Az](https://www.amazon.es/Samsung-960-EVO-NVMe-M-2/dp/B01M7P06DY/)][[Vendedor](https://www.samsung.com/us/computing/memory-storage/solid-state-drives/ssd-960-evo-m-2-500gb-mz-v6e500bw/)]
- SAI: CyberPower 1000VA 8AC 600W (BR1000ELCD) [[Az](https://www.amazon.es/CyberPower-BR1000ELCD-interactiva-alimentaci%C3%B3n-ininterrumpida/dp/B01FCDGEYK)][[Vendedor](https://www.cyberpower.com/eu/es/product/sku/br1000elcd)]
- HDD: 4 × Toshiba 16 TB (MG08ACA16TE) [[Az](https://www.amazon.es/gp/product/B0832BL1HC)][[Vendedor](https://toshiba.semicon-storage.com/ap-en/storage/product/data-center-enterprise/cloud-scale-capacity/articles/mg08.html)]
<a name="consideraciones"></a>

### 4.1 - Algunas consideraciones:

Después de analizar bastante mi caso de uso elegí el **Synology 920+** [[especificaciones](https://global.download.synology.com/download/Document/Hardware/DataSheet/DiskStation/20-year/DS920+/enu/Synology_DS920_Plus_Data_Sheet_enu.pdf)] por tener cuatro bahías y un procesador suficiente pero no excesivo. Debo hacer notar que el NAS lo pretendo para copia de seguridad y levantar algunos servicios. No tengo interés, en principio, en montarme una estación multimedia. No obstante, cabe destacar por lo que he ido leyendo sobre este modelo que es más que suficiente para servir vídeo por DLNA y correr Plex, aunque puede ir algo corto en transcoding 4k vía software.

El **procesador** que monta el 920+ es un Intel Celeron J4125 [[especificaciones](https://ark.intel.com/content/www/us/en/ark/products/197305/intel-celeron-processor-j4125-4m-cache-up-to-2-70-ghz.html)], 2.0-2.7 GHz con 4MB de caché y 10 W de TDP. Este NAS **consume poco** y es muy **silencioso**, además integra motor de cifrado por hardware (conjunto de instrucciones **AES-NI**), que reduce con mucho el impacto en E/S para carpetas cifradas [[5](https://www.scottbrownconsulting.com/2011/10/a-look-at-the-performance-impact-of-hardware-accelerated-aes/)], [[6](https://www.kitguru.net/professional/networking/simon-crisp/synology-diskstation-ds920-4-bay-nas-review/10/)]. Como contrapartida, el procesa pagina un máximo de 8 Gb de RAM. El Synology 920+ viene de fábrica con 4 Gb soldados en placa y una única bahía adicional libre.

Por [internet](https://www.reddit.com/r/synology/search/?q=920%20ram%2016%20Gb&restrict_sr=1&sr_nsfw=) se puede encontrar a gente que ha instalado el módulo adicional con 16 Gb para un total de 20 Gb. Sin embargo, en las propias especificaciones del procesador indica que el máximo son 8 Gb. Existen, asimismo en internet, reportes de usuarios con problemas de estabilidad por haber montado en el zócalo un módulo de 16 Gb. Así que he sido conservador y me hecho con únicamente **4 Gb adicionales** de Crucial. Si bien, aunque en el [hardware compatible](https://www.synology.com/es-es/compatibility?search_by=products&model=DS920%2B&category=rams&p=1&change_log_p=1) certificado de Synology no aparece este módulo de RAM concreto, en la propia página de Crucial del componente [sí lo indica](https://www.crucial.com/compatible-upgrade-for/synology/ds920-). Con el [SSD M.2](https://www.synology.com/es-es/compatibility?search_by=products&model=DS918%2B&category=m2_ssd_internal&p=1&change_log_p=1) sucede que no aparece como compatible para el 920+ pero sí para el 918+. La gente reporta que no tiene problemas con este modelo de M.2 en el 920+, yo hasta el momento tampoco he tenido ninguno.

Acerca de los discos duros **M.2** que permite montar el Synology 920+ se debe decir que son **para caché**, exclusivamente. Tiene dos bahías M.2 para tal fin. Si se pretende una memoria caché de lectura es necesario al menos un disco, con 500 Gb sobra. Si se desea lectoescritura son necesario dos discos M.2 para montar RAID 1 entre ellos, más sobre los sitemas RAID [luego](#raid). La razón de esta RAID 1 se debe al interés de mantener la integridad de los datos en la caché que luego será copiada en los discos mecánicos del NAS. Hay que pensar el tema de los M.2 para caché con calma; la mejora puede ser sustancial, en efecto, pero siempre dependiendo del caso de uso. Para mí no representa ventaja una memoria rápida de lectoescritura, aunque sí he pensado oportuno tener una caché de lectura tanto para navegar con más soltura por el disco como para agilizar las peticiones recurrentes contra mis servicios. Dudo de que en la mayoría de los casos domiciliarios estas memorias caché sean necesarias. 

Sobre el **SAI** no hay mucho que añadir, me decanté por uno con suficientes buenas referencias dentro de la lista de componentes compatibles. Me importaba que pudiese tirar al menos dos horas con la carga del NAS, del ONT y el router. Hice un cálculo burdo y aproximado de pontecia: 20 W del NAS + 4 * 5 W de los hdd + 20 W del router = 60 W, pongámosle 100 W, debería dar sobradamente **para cubrir 6 horas el rig**. Además, aprovecho los puertos del SAI sin batería para interponerlos ante mi *workstation*. He de añadir que me ha sorprendido gratamente la integración del SAI con DSM 7, el OS de Synology, por USB. He configurado el NAS para que se apague automáticamente si la batería del SAI está por debajo del 10% y descargándose. También lo he configurado para que se levante automáticamente cuando se recupere la alimentación.

Sobre el tema de los discos duros, como me he metido con esto en profundidad, le haré su propia sección.
<a name="hdd"></a>
# 5 - Discos Duros
Ahora sí viene la chicha, ¡qué discos duros escoger! Me he pasado largas horas analizando y decidiendo y descartando. Plasmo el resultado de forma secuencial por características. Empezaré por **1 - El tamaño**, para luego pasar a elegir **2 - El modelo**, después **3 - El formato** y terminaré hablando de **4 - La RAID**.
<a name="tamanio"></a>
### 5.1 - El tamaño
Por supuesto que los discos duros son el apartado más importante de un NAS, así que me he dedicado con fruición a refrescar sus entresijos para escoger la mejor de las opciones para mi caso de uso. Comenzaré por el **tamaño: 4 × 16 Tb para un total de 64 Tb**. Puede parecer mucho, pero dado que pienso montar un raid con dos discos de redundancia (más sobre esto [luego](#raid)), en realidad son 32 Tb disponibles. Para un uso común, domiciliario como digo, este volumen puede seguir pareciendo alto, sobre todo si no pretendo un servidor multimedia como he indicado antes. Así que justificaré tales dimensiones:

He perdido 5.5 Tb de datos. Estos datos fueron registrados/creados desde 2008 hasta 2022. Si la tendencia fuese lineal en 2036 dispondría de 11 Tb. Pero todos sabemos que la tendencia no es para nada lineal, sino más bien exponencial (cfr. [Imagen 2](#imagen2)). Baste con recordar que el tamaño de las fotografías JPG hace una década raramente excedía los 300 Kb, y hoy rondan hasta la decena de Mb. La creación y conservación de datos terminará siendo un problema de recursos y energía, pero eso es otra historia que merece otro hilo. Si nos paramos un momento a estimarla no es descabellado pensar en una tasa de crecimiento instantánea de 0.4-0.5 anual, bastante conservadora según la [Imagen 2](#imagen2). 

Para calcular  burdamente mi uso de datos a 10 años vista, tendré en cuenta que si he creado 5.5 Tb de datos en los últimos 14 suponen linealmente unos 400 Gb anuales. Si ahora calculamos la función exponencial con estos 400 Gb y la tasa de crecimiento entre 0.4 y 0.5... en los próximos 10 años podría aproximar mi creación de datos entre 22 y 60 Tb. Así que una configuración de 32 Tb, [expandible](https://www.synology.com/en-us/products/DX517#specs) en el Synology 920+ a través de e-Sata por un [DAS](https://es.wikipedia.org/wiki/Almacenamiento_de_conexi%C3%B3n_directa) (almacenamiento de conexión directa o ***D**irect **A**ttached **S**torage* en inglés, un conjunto de discos duros), no es un mal lugar donde empezar.
<a name="imagen2"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/IzzpiSw.png)

*Imagen 2. Tendencia de la* dataesfera *global. Seagate [[7](https://www.seagate.com/files/www-content/our-story/trends/files/idc-seagate-dataage-whitepaper.pdf)]*

Tal como he establecido con anterioridad, pretendo **montar una copia reflejo de mi disco duro de datos**, pero también deseo montar **una nube privada virtual** tanto para mí como para mi pareja. Seguiré usando nubes propietarias para continuar guardando lo sensible y lo que deba ser compartido intra-empresa. Me gustaría no tener que volver a tocar Dropbox de forma personal y cotidiana. De hecho, las limitaciones de espacio y de número de dispositivos vinculados de Dropbox son bastante malas de un tiempo a esta parte, además de que me parece un software muy intrusivo. Por último, tanto Dropbox como GDrive como OneDrive realizan escaneos sobre los datos que sus usuarios alojan en la nube. No tengo nada que esconder, pero la privacidad es un hito. A este respecto, es posible que me monte mi propio GitLab.
<a name="modelo"></a>
### 5.2 - El modelo
Estuve informándome largo sobre qué discos duros adquirir. En principio, la opción más segura era la opción NAS (red) de Wenster Digital. También SeaGate NAS (Ironwolf) me llamaba. Debía llegar a un acuerdo entre el coste de los discos y la fiabilidad de los mismos. Lo que hice fue lo siguiente:

- Gracias a [diskprices.com](https://diskprices.com/?locale=es&condition=new&capacity=6-&disk_types=internal_hdd) listé los precios de los discos en Az y me fijé en el precio por Tb
- De los discos que me suscitasen interés busqué su compatibilidad certificada o probada con el Synology
- De los discos filtrados de este modo busqué información y referencias

Si bien quería ceñirme a los discos duros de NAS por su fiabilidad y bajo nivel de ruido, finalmente el precio tuvo peso. Los discos duros que escogí fueron los **Toshiba MG08ACA16T de 16 TB**. Estos discos no están en la lista de hardware compatible con Synology 920+ pero sí en [la lista del 918+](https://www.synology.com/es-es/compatibility?search_by=products&model=DS918%2B&category=hdds_no_ssd_trim&p=1&change_log_p=1). En foros, la gente reportaba su buen funcionamiento, aunque cuando los instalas sale un *disclaimer* de Synology advirtiendo que estos modelos no han sido testados en el 920+.

Acerca de la información y referencias, entre otras muchas cosas me fijé la tasa de errores reportados por discos y modelos [aquí](https://www.backblaze.com/blog/backblaze-drive-stats-for-2021/), lo que me ayudó a decantarme por Toshiba, con una relación de fallo anualizado del 0.91%, segunda posición en esa lista de 24 modelos de alta fiabilidad. Me fijé asimismo en que no fueran SMR [[8](https://naseros.com/2020/05/03/diferencias-entre-smr-cmr-y-pmr/)], una implementación tecnológica interesante pero no apropiada para NAS y RAID.

Sobre el disco debo decir que está compuesto de **9 platos sellados en helio a 7200 revoluciones por minuto**. Este sellado en helio le permite operar a esta velocidad sin problemas de calentamiento con el rozamiento del aire. Además, incorpora sensores de rotación y, si no recuerdo mal, está recomendado para *racks* de hasta 10 discos duros. Esto es curioso, porque no había pensado yo nunca en la suma constructiva de las vibraciones entre discos duros adyacentes (fenómenos de resonancia) que podrían poner en peligro la integridad o la facilidad de acceso a la información. 

La baja tasa de vibración y de calor lo convierte en un **disco suficientemente silencioso**. La versión del disco que he elegido es la **SATA**, existiendo también una versión SAS (ergo de mayor transferencia), porque es el interfaz del Synology 920+. Por último, los sectores físicos de este disco son **512e y no los más modernos 4k**  [[9](https://i.dell.com/sites/csdocuments/Shared-Content_data-Sheets_Documents/en/512e_4Kn_Disk_Formats_120413.pdf)];  es un mal menor para poder disfrutar de sus prestaciones a este precio tan bueno. He de añadir que son discos duros para servidores, no específicamente para NAS. No son totalmente silenciosos, sino que **emiten un ruido tipo pedregoso y ligero, rítmico cada 2 segundos**. En mi condición no supone problema.
<a name="formato"></a>
### 5.3 - El formato

Una de las cosas que más me ha sorprendido al aventurarme a este proyecto es el descubrir sobre la existencia de [BTRFS](https://es.wikipedia.org/wiki/Btrfs), que por descontado muchos conoceréis. Siendo mi trasfondo no de sistemas, me ha parecido una delicia. **BTRFS es un sistema de formato de archivos desarrollado por Oracle** muy, muy interesante. Los sistemas a los que estamos acostumbrados suelen ser extFAT, NTFS o EXT4, por ejemplo. Estos funcionan  mediante tablas que relacionan  los archivos en el disco/partición (y su jerarquía) con su dirección física en el disco duro (sector) (cfr. [Imagen 3](#imagen3)), en sistemas de archivos de Windows (NTFS, Fat...) se usa *[mft](http://ntfs.com/ntfs-mft.htm)*, en sistemas de archivos de Unix (EXT...), *[inode](https://en.wikipedia.org/wiki/Inode_pointer_structure)*. 
<a name="imagen3"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/nqWqLay.png)

*Imagen 3. Esquema de tablas con la relación de archivos en NTFS (izquierda) y EXT (derecha). Imagen adaptada de [ntfs.com](http://ntfs.com/ntfs-mft.htm) y [Wikipedia](https://en.wikipedia.org/wiki/Inode_pointer_structure).*

Tanto en mft como en inode, cuando se crea un archivo se guarda su nombre, su jerarquía en y se registra dónde los datos almacenados comienzan físicamente en el disco (sector). Al editar un archivo y guardarlo, este enlace entre el nombre del archivo en la tabla y su dirección física en el disco duro se cambia: ahora el archivo apunta a esta otra dirección. El espacio antiguo del disco se marca como disponible para escritura. En esto radica la posibilidad de poder recuperar archivos borrados siempre y cuando su dirección física no haya sido reasignada a nuevos datos, escaneando la superficie del disco. Podríamos charlar sobre lo que es el tamaño de sector y de lo que significa la fragmentación, etc., pero eso sería desviarnos del tema.
<a name="imagen4"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/ViSFMyH.png)

*Imagen 4. Esquema BTRF en disco [[10](https://docs.docker.com/storage/storagedriver/btrfs-driver/)]*

Lo que BTRFS viene a traernos, en contraste, es un sistema incremental de cambios en los archivos. ¿Qué quiere decir esto? Que yo guardo un archivo hoy, mañana lo edito y lo vuelvo a guardar, y lo que ocurre es que se crea un nuevo apunte en el disco indicando qué ha cambiado sobre la información que había guardado ayer. Es decir, en contraste con los sistemas usuales donde se guardaría enteramente el archivo editado en un nuevo espacio de memoria, con **BTRFS lo que hacemos es registrar los cambios sobre lo que había guardado** (cfr. [Imagen 4](#imagen4)). Esto supone una mejora sustancial, porque **podemos reconstruir en el tiempo las diferentes versiones (deltas) de un archivo**. Además, para cada apunte sobre un archivo o sus actualizaciones, podemos disponer de un **checksum y así comprobar la integridad de la información/modificaciones en el tiempo**, lo que otorga un control sobre posibles bitflips y degradaciones de memoria [[11](https://en.wikipedia.org/wiki/Data_degradation)], [[12](https://en.wikipedia.org/wiki/Single-event_upset)].
<a name="raid"></a>
### 5.4 - La RAID

¿Qué es un **RAID**? Grosso modo un sistema [RAID](https://es.wikipedia.org/wiki/RAID) es un tipo de arreglo de configuración entre los discos duros. Las siglas atienden a ***R**edundant **A**rray of **I**ndependent **D**isks*, es decir un grupo redundante de discos duros independientes. Dependiendo del objetivo, existen varias formas estándar de RAID, siendo las más famosas, RAID 0, RAID 1, y RAID 5. Para comprender bien de lo que estamos hablando haré una muy breve explicación sobre estas configuraciones.
<a name="imagen5"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/NpaRz2B.png)

*Imagen 5. Esquemas de RAID 0, RAID 1 y RAID 5, respectivamente. Imagen adaptada de  [Wikipedia](https://es.wikipedia.org/wiki/RAID)*

- **RAID 0**: suma directa de dos o más discos duros. Nótese cómo las partes de información de un mismo archivo se reparten indistintamente entre los discos (cfr. [Motivacion](#motivacion)) y de aquellos barros estos lodos.
- **RAID 1**: copia reflejo de un disco en al menos otro disco (cfr. [Imagen 5](#imagen5)). La información es duplicada por el número de discos del sistema, así que si falla un disco existe respaldo en el otro. Tiene la ventaja de que la lectura es tantas veces rápida como el número de discos del conjunto, pero la escritura es la misma que un solo disco. Además, el tamaño del conjunto es igual al disco de menor tamaño del conjunto, el resto de memoria no se aprovecha.
- **RAID 5**: Sistema de tres o más discos. Un disco del conjunto guarda la paridad de datos (cfr. [Imagen 5](#imagen5)); que en esencia implica redundancia de datos pero de una forma ingeniosa mediante cálculos xor entre los bloques [[13](https://www.runtime.org/help_raid_chm/xor.htm)]. La velocidad de lectoescritura es elevada, aunque no la suma directa de la lectoescritura del conjunto. La capacidad es la del conjunto menos un disco. Como contrapartida, el tamaño útil de cada uno de los discos queda limitado al menor de los tamaños entre los discos, el resto de memoria no se aprovecha.

Uno de los arreglos **más utilizado** a nivel domiciliario y pequeña empresa es **el RAID 5**, porque sacrificando un solo disco se tiene tanto redundancia de datos como las ventajas de lectoescritura de varios discos. Hay que tener en cuenta que las recuperaciones de RAID suelen ser largas y tediosas, con tiempos de reconstrucción de información de varios días, dependiendo del caso. Bueno, en RAID 0 no hay nada que reconstruir, lo has perdido todo. En RAID 1 tampoco hay nada que reconstruir, porque tienes la copia reflejo.

<a name="shr"></a>
### 5.5 - SHR

Llegado a este punto tuve que decidir qué tipo de arreglo quería. Estuve valorándolo con calma. De entre las opciones llegué a un sistema RAID propietario de Synology, el [SHR](https://kb.synology.com/es-mx/DSM/tutorial/What_is_Synology_Hybrid_RAID_SHR). **El SHR es un sistema muy parecido a RAID 5 pero con una ventaja, los discos duros se dividen internamente en volúmenes y se producen múltiples paridades siempre que para el volumen n haya al menos dos o más copias en diferentes discos físicos**. El efecto directo de esto es que se minimiza el tamaño de memoria no aprovechado, ideal para sistemas RAID con discos de tamaño dispares o para aquellos pensados como ampliables en un futuro.

Para explicarlo mejor daré un ejemplo con tres discos dispares, de 8, 4 y 2 Tb, divididos todos ellos en volúmenes de 2 Tb para SHR, comparándolo con los resultados de diferentes configuraciones RAID.

***Sean los discos duros A, B, C con tamaños 8, 4 y 2 en Tb respectivamente, divididos todos ellos en volúmenes de 2 Tb de la forma***:

1. Disco A (8 Tb): Volumen1, Volumen2, Volumen3, Volumen 4
2. Disco B (4 Tb): Volumen1, Volumen2,
3. Disco C (2 Tb): Volumen1

Con este arreglo, no óptimo por los tamaños de los discos elegidos, tendríamos el **Volumen 1 (2 Tb) con paridad (2 Tb)**, también el **Volumen 2 (2 Tb) con paridad (2 Tb)**, pero **perderíamos Volumen 3 (2 Tb) y Volumen 4 (2 Tb) por no haber con qué parearlos**. En síntesis dispondríamos de 4 Tb de datos disponibles, con 4 Tb de redundancia y 4 Tb de memoria sin aprovechar.

En contraste, con RAID 5 tendríamos: 4 Tb útiles con 2 Tb de redundancia y 8 Tb perdidos. Con RAID 1 tendríamos 2 Tb útiles con 2+2 Tb de redundancia y 8 Tb perdidos y con RAID 0 tendríamos 14 Tb útiles con 0 Tb de redundancia. Sintetizo este ejemplo en la [Tabla 1](#tabla1):
<a name="tabla1"></a>

| RAID  | DISPONIBLE | REDUNDANCIA | PERDIDO |
|-------|------------|-------------|---------|
| SHR   | 6          | 2+2         | 4       |
| RAID 5 | 4          | 2           | 8       |
| RAID 1 | 2          | 2+2         | 8       |
| RAID 0 | 14         | 0           | 0       |

*Tabla 1. Ejemplo de diferentes sistemas de RAID para la configuración de 3 discos duros de tamaños 8 Tb, 4 Tb y 2 Tb, indicando la cantidad de memoria aprovechada, la destinada a redundancia y la perdida.*

Nota: Cuando ya había escrito todo este ejemplo he encontrado una imagen sobre lo mismo pero con un ejemplo diferente, la pondría aquí pero por la diferencia en los ejemplos no aclararía, así que solo la [enlazo](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/Ufy9xT4.jpeg).

Explicados estos tipos de RAID puedo hablar de RAID 6 y de SHR2. RAID 6 es como RAID 5 pero con doble paridad al igual que SHR-2 es como SHR pero con doble paridad. Esto significa que el conjunto de discos es suficientemente robusto como para perder hasta dos discos de forma simultánea conservando la integridad de la información. **Para mi NAS he escogido un sistema RAID SHR-2**. 

Como he dicho, el sistema SHR es propietario. Antaño esto podía suponer algún problema de compatibilidad para poder montar las unidades en \*nix, pero eso ya no hoy. Cabe destacar que el SHR-2 entraña, como he dicho, un sistema de tolerancia de hasta dos discos. Si en el largo plazo deseo ampliar el sistema pongamos con dos discos similares, pasaría a tener 64 Tb útiles (cuatro discos) + 32 Tb de redundancia (dos discos).

Nota: Synology dispone de una calculadora de RAIDs interactiva y muy maja que ayuda a entender los tamaños finales disponibles según la configuración (aunque no explican el porqué de esos tamaños). Podéis jugar con la calculadora [aquí](https://www.synology.com/es-es/support/RAID_calculator?hdds=8%20TB|4%20TB|2%20TB).

<a name="instalacion"></a>
# 6 - Instalación del NAS

Como última parte de este hilo hablaré de la muy sencilla instalación del producto y de cómo he chequeado el hardware.
<a name="instalacionhdd1"></a>
### 6.1 - Chequeo de los discos duros: 1º FASE
Los discos me llegaron antes que el NAS. He de decir que llegaron cada uno en una bolsa antiestática y punto. Había leído en [Amazon](https://www.amazon.es/product-reviews/B0832BL1HC/ref=acr_dp_hist_1?ie=UTF8&filterByStar=one_star&reviewerType=all_reviews#reviews-filter-bar) que la gente los recibía así, pero no me lo creía. En efecto, me llegaron 3 discos duros en un sobre de papel sin acolchar, y estos discos cada uno en una simple bolsa antiestática. El cuarto disco me llegó también en una bolsa antiestática, pero en una caja. Muy mal para Amazon aquí, pues es quien vendía y enviaba el producto.
<a name="imagen6"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/WXPaVg7.png)

*Imagen 6. Test de lectoescritura en CrystalDiskMark para sendos 4 discos duros. Nótese que las velocidades de lectoescritura están limitadas por el interfaz USB.*

Todos sabemos lo sensibles que son los discos mecánicos a los golpes y a las vibraciones, así que actué de la siguiente manera: Lo primero que hice fue un chequeo visual de la integridad externa de cada disco duro. No había desperfectos, menos mal. Después los conecté uno a uno a mi ordenador personal a través de una interfaz USB3-SATA [[Az](https://www.amazon.es/gp/product/B016UBXH3O)] para testarlos. Nada más conectarlos lo primero en lo que me fijé fue en el sonido siendo en todos los casos normal. Lo siguiente fue centrarme en los valores [S.M.A.R.T](https://es.wikipedia.org/wiki/S.M.A.R.T.) de cada uno de ellos mediante el [CrystalDiskInfo](https://crystalmark.info/en/software/crystaldiskinfo/). Esta palabra viene de ***S**elf **M**onitoring **A**nalysis and **R**eporting **T**echnology*, un sistema de autoanálisis estándar que integran la ya totalidad de discos duros.

Mientras monitorizaba el S.M.A.R.T. hice una prueba de lectoescritura mediante el [CrystalDiskMark](https://crystalmark.info/en/software/crystaldiskmark/) (cfr. [Imagen 6](#imagen6)). Esta prueba de lectoescritura sucede en cuatro fases alternando lecturas y escrituras secuenciales y aleatorias de diferentes tamaños. El objetivo era claro: estresar los discos y ante el mínimo error de un solo sector cambiarlos por unos nuevos. Por suerte no presentaron fallos y estas pruebas no me llevaron más de una hora. Supongo que el mal embalaje se debe al buen precio de los discos.
<a name="instalacionhdd2"></a>
### 6.2 - Chequeo de los discos duros: 2º y 3º FASE

Una vez el NAS estuvo en mi poder procedí a instalar los discos, arrancar por vez primera el Synology y realizar la configuración inicial del DSM 7, su sistema operativo. Antes de montar un volumen con los discos pasé una segunda prueba rápida de S.M.A.R.T. en cada uno desde el propio sistema operativo. Lo bueno es que se realiza la prueba de forma paralela, por lo que es más rápido: terminó correctamente en menos de media hora. Una vez superada, hice una tercera prueba en cada disco, pero esta vez de S.M.A.R.T. extendida. La prueba "extendida" es un tipo de prueba que ofrece DSM pero de la que no he encontrado información técnica. Hasta donde yo entiendo se desarrolla chequeando toda la superficie del disco. Tomó bastante más tiempo, unas 30 horas. Tras finalizar positivamente, por fin monté el volumen de los discos en formato BTRFS y RAID SHR-2, concluyendo con un tamaño útil de 32 Tb + 32 Tb de redundancia (tolerancia de fallo de dos discos).
<a name="instalacionram"></a>
### 6.3 - Instalación de la ampliación de RAM

Esta parte fue sencilla: apagué el aparato, lo abrí e inserté el módulo. Al reiniciar el DSM pude ver que se reconocía correctamente la totalidad de los 8 Gb de RAM (4 Gb soldados en placa más los 4 Gb recién instalados). Para realizar una prueba de integridad en la RAM tuve que instalar el [Synology Asystant](https://kb.synology.com/es-mx/DSM/help/Assistant/assistant?version=6) (cfr. [Imagen 7](#imagen7)) en mi ordenador personal y una vez reconocido el NAS lanzar mediante LAN el test de RAM.
<a name="imagen7"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/LlJ8g4Q.png)

*Imagen 7. Captura de pantalla del Synology Asystan habiendo reconocido correctamente el Synology 920+. Nótese del menú emergente la opción de "Prueba de memoria".*

Como es lógico, esto reinicia el sistema para dejar casi completamente vacía la RAM y comienza a realizar la prueba. En concreto también desconozco cómo funciona esta prueba técnica, pero la forma usual es hacer barridos en la RAM llenándolos de un valor para luego comprobar que los valores son persistentes. Llevó un par de horas (?) y finalizó correctamente.
<a name="instalacionm2"></a>
### 6.4 - Instalación del M.2 SSD Caché

Para terminar la instalación del hardware, lo último fue instalar el M.2 SSD que hace la función de caché solo de lectura del NAS. Este paso fue trivial: apagar el NAS, abrir una de las dos pletinas inferiores de la caja, instalar el M.2 y reiniciar. Al reiniciar se reconoció sin problema alguno. Hecho esto, fui a la configuración de discos y establecí este como memoria caché. Hago notar que este M.2 lo tenía por casa con una integridad de más del 90% con cuatro años de uso como disco principal de sistema operativo de mi ordenador personal. Contando con que este modelo tiene unos 400 TBW de vida útil aún creo que le podré sacar rendimiento por una buena temporada.
<a name="final"></a>
# 7 - Palabras finales

Muchas gracias por acompañarme hasta aquí. Hemos recorridola selección del NAS, de la ampliación de RAM, de la selección de M.2. para cache y de los discos duros de datos y su arreglo de formato y RAID. Mediante este hilo podéis seguir el discurso de pensamiento y acción que he llevado para la adquisición de mi NAS de respaldo a medio y largo plazo, y microservicios. Nunca, y digo, NUNCA más permitiré que me vuelva a ocurrir una pérdida de datos como la que he sufrido o, al menos, haré todo lo que pueda para que no vuelva a pasar.  Espero que os haya sido entretenido.
<a name="imagen8"></a>
![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/ojk8rtc.png)

*Imagen 8. Captura de pantalla con la información del hardware final del Synology DS920+ HDA-NAS.*

<a name="futuro"></a>
### 7.1 - Para el futuro

Hay algunas cosas con las que, al respecto del hardware, puedo jugar en un futuro. En especial se trataría de hackear el DSM para instalar una tarjeta de red USB3 de 2.5 o 5 Gbit/s, ideal de 10 Gbit/s. Pero he preferido ser conservador porque aún me queda mucho camino que configurar y desarrollar en este, mi proyecto de HDA-NAS.
<a name="continua"></a>
### 7.2 - ¡Continúa con la serie!

1. [Este](https://github.com/backmind/tutorials/hda-nas.md) hilo que os comparto es el primero de una serie de tres que proyecto y trata sobre el hardware que he montado y por qué. 
2. [El segundo hilo](https://github.com/backmind/tutorials/hda-serv.md) trata sobre la configuración básica de un servidor. 
3. El tercer hilo sobre microservicios personales para proyectos y jugueteos que me gustaría hacer.

---

### Versión 1.1R2 (26/02/2022)

[ancla]changelog[/ancla]
###  Changelog
- Versión 1.1R2 (04/12/2022)
    - Corregidas un montón de erratas
    - Añadido el hipervínculo al segundo hilo de la trilogía
- Versión 1.1R1 (26/02/2022)
    - Corregidas un montón más de erratas
    - Reestructura de la sección SHR para hacerla más comprensible
    - Añadidas algunas referencias adicionales
- Versión 1.1R0 (25/02/2022)
    - Corregidas un montón de erratas
    - Reformulación y explicación de parte de los procesos
    - Cambiada la mención del LBA por mft e inodes, para ser más específico
    - Imagen nueva sobre mft e inodes
    - Nuevas anclas a lo largo del texto y para cada imagen y tabla
    - Hipervinculadas las referencias a imágenes y tablas
- Versión 1.0R0 (24/02/2022)
    - Versión inicial.



![](https://github.com/backmind/tutorials/blob/main/hda-nas-assets/x2OCV3r.png)

Esta obra está bajo una licencia Reconocimiento-No comercial 4.0 de Creative Commons. Para ver una copia de esta licencia, visite https://creativecommons.org/licenses/by-nc/4.0/deed.es o envíe una carta a Creative Commons, 171 Second Street, Suite 300, San Francisco, California 94105, USA.
