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


for file in "$aceptados/"*.csv;
do
while IFS=',' read TO OPDes trx FC anio FH col7 col8 col9 col10 TN CR RN col14 col15 col16 col17 MH
	do				
		if [[ "$TO" != "CI" ]]; 								# Modifico Internal Field Separator por ","
		then													# To = Tipo Operacion		OPDes = Descripcion Oper
			let CONTADOR=CONTADOR+1								# trx = cantidad tran 		TR = Trace Number
		else													# FC = Fecha Cierre Lote	FH = Fecha y Hora
			if [[ "$CONTADOR" = "$trx" ]]						# CR = Código de Respuesta ISO 8583
			then 												# RN = Reference Number 	MH = Mensaje del Host	
				nombreArchivo="${file##*$novedades/}"			# El resto se calcula con MH
				procesar
				CONTADOR=0
			else
				mv $file $rechazados			# Mueve a la carpeta de rechazados
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

function procesar
{
archivoCierre="Cierre_de_$nombreArchivo"
touch "$archivoCierre"
nBatch=${MH:5:3}
cantCompras=${MH:8:4}
montoCompras=${MH:12:1}
cantDevolu=${MH:13:4}
montoDevolu=${MH:17:1}
cantAnul=${MH:18:4}
montoAnul=${MH:22:1}
echo -e $TO,$OPDes,$trx,$FC,$anio,$FH,$TN,$CR,$RN,$MH,$nBatch,$cantCompras,$montoCompras,$cantDevolu,$montoDevolu,$cantAnul,$montoAnul >> "$archivoCierre"

#echo $nBatch
#echo $cantCompras
#echo $montoCompras
#echo $cantDevolu
#echo $montoDevolu
#echo $cantAnul
#echo $montoAnul

mv $archivo $procesados						# Mueve a la carpeta de procesados
mv $archivoCierre $cierreLotes 						# Mueve a la carpeta de Cierre_de_Lotes

# Grabar en el log “Batch Nº xxx ($nBatch) grabado en cierre de lote"
$BINDIR./glog.sh "proc" "Batch Nº: $nBatch grabado en cierre de lote"

return 0

}

# Cuerpo Principal


CICLO=0
PROCESO_ACTIVO=true

carpetas=$(pwd)
novedades="$DIRNOV"
aceptados="$DIROK"
rechazados="$DIRNOK"
procesados="$DIRPROC"
cierreLotes="$DIROUT"

$BINDIR./glog.sh "proc" "Procesando... "
function finalizar_proceso {
   let PROCESO_ACTIVO=false
}


trap finalizar_proceso SIGINT SIGTERM


while [ $PROCESO_ACTIVO = true ]
do
	for file in "$novedades/"*.csv;
	do
		set CICLO=CILO+1
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
	done

	validar_cantidad_trx

	sleep 10

	#loggear el CICLO en el que voy
	$BINDIR./glog.sh "proc" "Ciclo Nº: $CICLO"

done

PID_PROCESO=`ps -a | grep proc.sh | awk '{print $1}'`
$BINDIR./glog.sh "proc" "Programa finalizado con pid: $PID_PROCESO"

exit 0

