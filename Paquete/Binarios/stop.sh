#!/bin/bash

NOMBRE_PROCESO=proc.sh
PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`

if [ -z $PID_PROCESO ]
then
  echo "ERROR: El programa no se encuentra ejecutado."
  $BINDIR/glog.sh "stop" "ERROR: El programa no se encuentra ejecutado."
else
  #mandamos senial para terminar el proceso	
  kill -15 $PID_PROCESO
  echo "Finalizando el programa con pid: $PID_PROCESO"
  $BINDIR/glog.sh "stop" "INFO: Finalizando el programa con pid: $PID_PROCESO"
fi

exit 0

