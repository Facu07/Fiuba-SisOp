#! /bin/bash

#cat <<-EOF

function validar_Existe_NoVacio_Regular
{

if [[ -s "$archivo" ]] 
then
	if [[ -r "$archivo" ]]; 
	then
		if [[ -f "$archivo" ]]; 
		then
			return 0								#Existe y no esta vacío && Exite y puede leerse 
		fi
		# Grabar en el log el nombre del archivo rechazado. Motivo: No es un archivo normal
		return -1
	fi
	# Grabar en el log el nombre del archivo rechazado. Motivo: No es legible
	return -1
fi
# Grabar en el log el nombre del archivo rechazado. Motivo: Archivo vacio
return -1

}

function validar_Nombre_Archivo
{

if [[ "$lote" = "Lote" ]]
then
	for (( i = 1; i < 100; i++ )); do
		if [[ "$(($nn))" = "$i" ]]
		then
			return 0
		fi
	done
fi
return -1

}

function validar_Archivo
{

if validar_Existe_NoVacio_Regular;
then
	if validar_Nombre_Archivo;
	then
		return 0
	fi
fi
return -1

}

function validar_cantidad_trx
{
CONTADOR=0

for file in $(ls);
do
	while IFS=- read col1 col2 col3 col4		# Modifico Internal Field Separator por "-"
	do
		if [[ "$col1" != "CI" ]]; 
		then
			let CONTADOR=CONTADOR+1
		else
			if [[ "$CONTADOR" = "$col3" ]]
			then
				echo "archivo valido"			# Los deja donde estan pq están bien
				CONTADOR=0
				procesar
				# PROCESAR LAS TRANSACCIONES y a GRABAR EL CIERRE DE LOTE
			else
				mv $file $rechazados			# Mueve a la carpeta de rechazados
				# Grabar en el log el nombre del archivo rechazado y bien en claro el motivo del rechazo:
				# cantidad de transacciones informadas en el cierre, cantidad en el lote
				# "$col3 tiene cantidad informada en el cierre"
				# "$CONTADOR tiene cantidad posta en el lote"
				CONTADOR=0
			fi
		fi
	done < "$file"
done
return 0

}

function procesar
{
mv $file $procesados
return 0

}


# Cuerpo Principal
echo
echo Inicio del cuerpo principal
echo

carpetas=$(pwd)
aceptados="$carpetas/aceptados"
rechazados="$carpetas/rechazados"
procesados="$carpetas/procesados"
cd Lotes/

for file in $(ls);
do
	nombreArchivo="$file"
	archivo=$file
	lote="${nombreArchivo%_*}"
	nn="${nombreArchivo##*_}"
	nn="${nn%*.csv}"
	if validar_Archivo; 
	then	
		mv $archivo $aceptados					# Mueve a la carpeta de aceptados
		# Grabar en el log el nombre del archivo aceptado
	else
		mv $archivo $rechazados					# Mueve a la carpeta de rechazados
	fi
done

cd ..
cd aceptados/

validar_cantidad_trx


echo
echo Fin Programa
echo

exit 0

