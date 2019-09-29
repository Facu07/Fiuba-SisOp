#!/bin/bash
#Glog - Script log errores

COMMAND="$1"
MSG="$2"
MAXSIZE=$LOGSIZE

if [ "$MAXSIZE" == "" ]; then
    MAXSIZE=5000000 
fi

if [ -z $3 ]; then
	TYPE="INFO"
else
	TYPE="$3"
fi
LOG_FILE="${COMMAND}.log"
 
setdir(){
	
	if [ ${COMMAND} == "instalacion" ]
	then
		DIRLOG="conf/log"
	else
		DIRLOG=$DIRLOG
	fi
}

checkdir (){
	if [ ! -d "${DIRLOG}" ]; then
		echo "Error: El directorio ${DIRLOG} no existe"
		exit 1
	fi
}

glog () {
	setdir
	checkdir

		
	if [ ! -f "${DIRLOG}/${LOG_FILE}" ]; then
	    FILESIZE=0
	else
	  FILESIZE=$(stat -c%s "${DIRLOG}/${LOG_FILE}")
	fi
	if [ ${FILESIZE} -gt ${MAXSIZE} ]; then
		echo -n "" > "${DIRLOG}/${LOG_FILE}"
		echo "$(date +%Y-%m-%d_%H:%M:%S) - Se elimina el log por exceder la capacidad maxima permitida de ${MAXSIZE} BYTES" >> "${DIRLOG}/${LOG_FILE}"
	fi 
	echo "$(date +%Y-%m-%d_%H:%M:%S) - ${USER} - ${COMMAND} - ${TYPE} - ${MSG}" >> "${DIRLOG}/${LOG_FILE}"
}

glog
exit 0
