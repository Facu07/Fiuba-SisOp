#! /bin/bash

function validar_Existe_NoVacio_Regular
{

if [[ -s "$archivo" ]] 
then
	if [[ -r "$archivo" ]]; 
	then
		if [[ -f "$archivo" ]]; 
		then
			return 0									#Existe y no esta vacío && Exite y puede leerse 
		fi
		# Grabar en el log el nombre del archivo rechazado. Motivo: No es un archivo normal
		$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es un archivo normal"
	fi
	# Grabar en el log el nombre del archivo rechazado. Motivo: No es legible
	$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: No es legible"
	return -1
fi
# Grabar en el log el nombre del archivo rechazado. Motivo: Archivo vacio
$BINDIR./glog.sh "proc" "$nombreArchivo rechazado. Motivo: Archivo vacio"
return -1

}

function validar_Nombre_Archivo
{

if [[ "$lote" = "Lote" ]]					# valido q la palabra sea "Lote"
then
	for (( i = 1; i < 100; i++ )); do 		# valido q el numero vaya de 01 a 99
		if [[ "$(($nn))" = "$i" ]]
		then
			return 0
		fi
	done
fi
return -1

}

function validar_Repetido
{


for file in "$procesados/"*.csv;
	do
		if [[ $archivo == $file ]];
		then
			# Grabar en log que se rechaza el $nombreArchivo por que esta duplicado
			$BINDIR./glog.sh "proc" "Se rechaza el $nombreArchivo por estar duplicado"
			return -1 
		fi
	done
return 0

}

function validar_Archivo
{

if validar_Existe_NoVacio_Regular;
then
	if validar_Nombre_Archivo;
	then
		if validar_Repetido;
		then
			return 0
		fi
	fi
fi
return -1

}

function validar_cantidad_trx
{
CONTADOR=0
CONTEO=0

for file in "$aceptados/"*.csv;
do
	if [ ! "$(ls $aceptados/)" ]
    then
    	$BINDIR./glog.sh "proc" "No hay archivos en $aceptados..."
    	echo "Se proceso todo en $aceptados"
    	return 0
    fi  
	while IFS=',' read TO OPDes trx FC anio FH NT venc importe cuotas TN CR RN ticket autori idTRX trxRel MH
	do
		nombreArchivo="${file##*$aceptados/}"	
		if [[ "$TO" != "CI" ]]; 								# Modifico Internal Field Separator por ","
		then													# TO = Tipo Operacion		OPDes = Descripcion Oper
			let CONTADOR=CONTADOR+1								# trx = cantidad tran 		TN = Trace Number
			procesarTransacciones
		else													# FC = Fecha Cierre Lote	FH = Fecha y Hora
			if [[ "$CONTADOR" = "$trx" ]]						# CR = Código de Respuesta ISO 8583
			then 												# RN = Reference Number 	MH = Mensaje del Host	
				procesarCierre									# NT = Numero de Tarjeta
				CONTADOR=0
			else
				mv $file $rechazados							# Mueve a la carpeta de rechazados
				# Grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo:
				# cantidad de transacciones informadas en el cierre, cantidad en el lote
				# "$trx tiene cantidad informada en el cierre"
				# "$CONTADOR tiene cantidad posta en el lote"
				$BINDIR./glog.sh "proc" "$nombreArchivo. Cantidad de transacciones informadas en el cierre: $trx. Cantidad en el lote: $CONTADOR"
				CONTADOR=0
			fi
		fi
	done < "$file"
done
return 0

}

function procesarCierre
{
archivoCierre="Cierre_de_$nombreArchivo"

nBatch=${MH:5:3}
cantCompras=${MH:8:4}
montoCompras=${MH:12:1}
cantDevolu=${MH:13:4}
montoDevolu=${MH:17:1}
cantAnul=${MH:18:4}
montoAnul=${MH:22:1}
echo -e $TO,$OPDes,$trx,$FC,$anio,$FH,$TN,$CR,$RN,$MH,$nBatch,$cantCompras,$montoCompras,$cantDevolu,$montoDevolu,$cantAnul,$montoAnul >> "$cierreLotes/$archivoCierre"

mv $file $procesados								# Mueve a la carpeta de procesados
#mv $archivoCierre $cierreLotes 						# Mueve a la carpeta de Cierre_de_Lotes

# Grabar en el log “Batch Nº xxx ($nBatch) grabado en cierre de lote"
$BINDIR./glog.sh "proc" "Batch Nº: $nBatch grabado en cierre de lote"
$BINDIR./glog.sh "proc" "Batch Nº: $nBatch y cantidad de transacciones: $CONTEO"
unset CONTEO


}

function procesarTransacciones
{

let CONTEO=CONTEO+1
tempanio=${anio:4:4}
tempFC=${FC:4:4}
mes=${FH:4:2}
dia=${FH:6:2}
hh=${FH:8:2}
mm=${FH:10:2}
ss=${FH:12:2}
monto=${importe:4:10}
decimales=${importe:14:2}
archivoTransaccion="TRX-$tempanio$mes$dia.csv"

if [ -z "$MH" ]; 
then
	codigoMensaje=${CR:5:2}
	while IFS=',' read cod descr refer
	do
		if [ "$codigoMensaje" == "$cod" ];
		then
			mensajeHost="$descr$refer"
		fi
	done < "$maestro/CodigosISO8583.csv"
else
	mensajeHost=${MH:5}
fi

echo -e $TO,$OPDes,$anio,$FH,$NT,$venc,$importe,$cuotas,$TN,$CR,$RN,$ticket,$autori,$idTRX,$trxRel,$mensajeHost,$mes,$dia,$hh:$mm:$ss,$monto.$decimales >> "$transacciones/$archivoTransaccion"


unset tempanio
unset tempFC
unset mes
unset dia
unset hh
unset mm
unset ss
unset monto
unset decimales


# Grabar en el log “Batch Nº xxx ($nBatch) grabado en cierre de lote"
#$BINDIR./glog.sh "proc" "Batch Nº: $nBatch grabado en cierre de lote"

}

# Cuerpo Principal


CICLO=0
PROCESO_ACTIVO=true

maestro="$DIRMAE"
novedades="$DIRNOV"
aceptados="$DIROK"
rechazados="$DIRNOK"
procesados="$DIRPROC"
cierreLotes="$DIROUT"
transacciones="$DIRTRANS"

$BINDIR./glog.sh "proc" "Procesando... "
function finalizar_proceso {
   let PROCESO_ACTIVO=false
}


trap finalizar_proceso SIGINT SIGTERM


while [ $PROCESO_ACTIVO = true ]
do
	for file in "$novedades/"*.csv;
	do
		let CICLO=CICLO+1
		if [ "$(ls $novedades/)" ]
    	then  
			nombreArchivo="${file##*$novedades/}"
			archivo=$file
			lote="${nombreArchivo%_*}"
			nn="${nombreArchivo##*_}"
			nn="${nn%*.csv}"
			if validar_Archivo; 
			then	
				mv $archivo $aceptados					# Mueve a la carpeta de aceptados
				# Grabar en el log el nombre del archivo aceptado
				$BINDIR./glog.sh "proc" "Archivo $archivo aceptado"
			else
				mv $archivo $rechazados					# Mueve a la carpeta de rechazados
			fi
     	else
         	echo "Nada por procesar"
         	$BINDIR./glog.sh "proc" "No hay archivos en $novedades..."
     	fi
		
	done

	if [ "$(ls $aceptados/)" ]
    then  
		validar_cantidad_trx
	fi

	sleep 10

	#loggear el CICLO en el que voy
	$BINDIR./glog.sh "proc" "Ciclo Nº: $CICLO"

done

PID_PROCESO=`ps -a | grep proc.sh | awk '{print $1}'`
$BINDIR./glog.sh "proc" "Programa finalizado con pid: $PID_PROCESO"

exit 0

