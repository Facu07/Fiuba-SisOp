#!/bin/bash

NOMBRE_PROCESO=proc.sh
CANT_PROCESOS_CORRIENDO=`ps -a | grep $NOMBRE_PROCESO | wc -l`

if [ $CANT_PROCESOS_CORRIENDO -gt 0 ]
then
  echo "el proceso ya se encuentra corriendo"
  exit 0
fi

#./proc.sh &>/dev/null &
./proc.sh &

echo "proceso iniciado"

exit 0

