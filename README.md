# FiubaSisOp
Repositorio Grupo 4 de Sistemas Operativos

-Documentación-

En el root del repositorio hay un script llamado maketgz.sh.

Al correr este script, se genera el .tgz que contiene el script del instalador (Install.sh) y el Paquete a instalar (que contiene el resto de los scripts y archivos de lotes).

Una vez descomprimido, correr el instalador con ./Install.sh.

El instalador detecta si el programa no está instalado, si está instalado correctamente, o si es necesario repararlo.

Para reparar el programa, en caso de ser necesario, se debe correr el script de instalación con el parámetro -r. (./Install.sh -r)

Los pasos que va realizando el Instalador, son logueados en el archivo grupo04/conf/log/Install.log

Inicialización del sistema.
inicio.sh se encarga de la inicialización del sistema.
Lee las variabels generadas por la instalación y guardadas en el archivo tpconfig.txt del directorio /conf.

Ejecucion del scripts:
1. moverse al directorio de archivos binarios (por defecto DIRBIN)
2. ejecutar el scripts de la sigueinte mandera:
            #. inicio.sh
            
3. una vez terminiada la inicialización tendrá disponible en su ambiente las variaralbes necesarias para correr el sistema
4. El scripts chequea existencia del archivo tpconfgi.txt, que todas las varibles necesarias esten presentes y definidas en el archivo, la existencia  de todos los directorios y los permisos de ejecución  de los  archivos presentes en el directorio de binarios. 
5. si no se cumplen esta condiciones la inicialización mostrará un mensaje de error y se deberá recuperar el sistema. 

Los archivos utilizados como ejemplo de parseo y como prueba, son los que se encuentran dentro de la carpeta "Paquete/Lotes". Al no econtrar especificacion en el enunciado de que tipos de .csv eran, los utilizados son del tipo .csv separados por "," (coma).
Dentro de los ejemplos también hay algunos ejemplos que se rechazan por tener nombre inválido o por transacciones no acorde con las del cierre.
