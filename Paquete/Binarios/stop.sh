#!/bin/bash

NOMBRE_PROCESO=proc.sh
PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`

if [ -z $PID_PROCESO ]
then
  echo "El programa no se encuentra ejecutado."
  
  if [ ! -z $BINDIR ]
  then
    $BINDIR/glog.sh "stop" "El programa no se encuentra ejecutado." "ERROR"
  fi

else
  #mandamos senial para terminar el proceso	
  kill -15 $PID_PROCESO
  echo "Finalizando el programa con pid: $PID_PROCESO"
  $BINDIR/glog.sh "stop" "Finalizando el programa con pid: $PID_PROCESO"
fi

exit 0

