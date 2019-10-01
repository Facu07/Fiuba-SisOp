# FiubaSisOp
Repositorio Grupo 4 de Sistemas Operativos

-Documentación-

En el root del repositorio hay un script llamado maketgz.sh.

Al correr este script, se genera el .tgz que contiene el script del instalador (Install.sh) y el Paquete a instalar (que contiene el resto de los scripts y archivos de lotes).

Una vez descomprimido, correr el instalador con ./Install.sh.

El instalador detecta si el programa no está instalado, si está instalado correctamente, o si es necesario repararlo.

Para reparar el programa, en caso de ser necesario, se debe correr el script de instalación con el parámetro -r. (./Install.sh -r)

Los pasos que va realizando el Instalador, son logueados en el archivo grupo04/conf/log/Install.log
