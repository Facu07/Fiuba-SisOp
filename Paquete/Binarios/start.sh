#!/bin/bash

if [ "$TP_SISOP_INIT" == "YES" ]
then

  NOMBRE_PROCESO=proc.sh
  CANT_PROCESOS_CORRIENDO=`ps -a | grep $NOMBRE_PROCESO | wc -l`

  if [ $CANT_PROCESOS_CORRIENDO -gt 0 ]
  then
    PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`
    echo "El programa porc.sh ya se encuentra ejecutado con pid: $PID_PROCESO"
    $BINDIR./glog.sh "start" "El programa proc.sh ya se encuentra ejecutado con pid: $PID_PROCESO"
    exit 0
  fi

  #start daemon
  $BINDIR./proc.sh &

  PID_PROCESO=`ps -a | grep $NOMBRE_PROCESO | awk '{print $1}'`
  echo "Se inicia proc.sh con pid: $PID_PROCESO"
  $BINDIR./glog.sh "start" "Se inicia proc.sh con pid: $PID_PROCESO"

else
  echo "El ambiente no fue inicializado."
  ./glog.sh "start" "El ambiente no fue inicializado.... ERROR"
fi

exit 0

