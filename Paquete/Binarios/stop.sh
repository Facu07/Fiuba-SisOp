#!/bin/bash

NOMBRE_PROCESO=proc.sh
PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`
DIRACTUAL=$(pwd)
cd ..
DIRLOG="$(pwd)/conf/log"
cd "$DIRACTUAL"
if [ -z $PID_PROCESO ]
then
	echo "El programa no se encuentra ejecutado."
	echo "$(date +%Y-%m-%d_%H:%M:%S) - ${USER} - stop - INFO - El programa no se encuentra ejecutado." >> "$DIRLOG/stop.log"
else
	#mandamos senial para terminar el proceso	
	kill -15 $PID_PROCESO
	echo "Finalizando el programa con pid: $PID_PROCESO"
	echo "$(date +%Y-%m-%d_%H:%M:%S) - ${USER} - stop - INFO - Finalizando el programa con pid: $PID_PROCESO" >> "$DIRLOG/stop.log"
fi

exit 0

