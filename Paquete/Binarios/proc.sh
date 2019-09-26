#!/bin/bash

PROCESO_ACTIVO=true

function finalizar_proceso {	 
   let PROCESO_ACTIVO=false
}

trap finalizar_proceso SIGINT SIGTERM

while [ $PROCESO_ACTIVO = true ]
do
   echo "procesando"
   sleep 5
done

echo "fin del proceso"

exit 0

