#!/bin/bash

NOMBRE_PROCESO=proc.sh
PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`

if [ -z $PID_PROCESO ]
then
  echo "el proceso no se encuentra corriendo"
else
  #mandamos senial para terminar el proceso	
  kill -15 $PID_PROCESO
  echo "proceso finalizado"
fi

exit 0

