#!/bin/bash

GRUPO=${PWD}/grupo04
DIRCONF=grupo04/conf
DIRLOG=grupo04/conf/log
DIRLOGBIN=Paquete/Binarios



main() {
	export GRUPO

	ISINSTALLED="$(ls -A grupo04)"
	if [ -d "$ISINSTALLED" ]; then
		necesitaRepararse="$(necesitaRepararse)"
		if [[ $necesitaRepararse = "si" ]]; then
			echo "Programa necesita reparación."
		fi
		if [[ $necesitaRepararse = "no" ]]; then
			echo "Programa instalado correctamente."
			mostrarDirectoriosElegidos
		fi
	fi
	if ! [ -d "$ISINSTALLED" ]; then
		instalarPrograma
	fi

}

instalarPrograma() {
	setearDirectoriosPorDefecto
	mkdir -m 777 grupo04
	mkdir -m 777 $DIRCONF
	mkdir -m 777 $DIRLOG
	verificarPermisosLogueo $DIRLOG/Install.log
	loguear "Inicio del proceso. Usuario: `whoami` Fecha y hora:  `date`" "INFO"
	loguear "Directorio de logs creado." "INFO"
	loguear "Directorio de config creado." "INFO"

	while [[ $CONFIRMO_DIRECTORIOS = "NO" ]]; do
		directorios=()
		elegirDirectorios
		mostrarDirectoriosElegidos
		confirmarInstalacion
	done
	grabarConfig
	creardirectorios

	DIRBIN="$(obtenerVariable DIRBIN)"
	verificarPermisoEjecucion "$DIRBIN/inicio.sh" || return 1
	loguear "Actualizando la configuracion del sistema" "INFO"
	loguear "Instalacion CONCLUIDA" "INFO"
	loguear "FIN del proceso. Usuario: `whoami` Fecha y hora:  `date`" "INFO"
	echo "Instalación finalizada"
	setearDireccionLoggerDefinitiva
}

setearDirectoriosPorDefecto() {
	DIRBIN=bin #a-El directorio de ejecutables
	DIRMAE=mae #b-El directorio de archivos maestros
	DIRNOV=nov #c-El directorio de arribo de archivos externos
	DIROK=ok #d-El directorio donde se depositan temporalmente los aceptados para que luego se procesen
	DIRNOK=nok #e-El directorio donde se depositan todos los archivos rechazados
	DIRPROC=proc #f-El directorio donde se depositan los archivos ya procesados
	DIROUT=out #g-El directorio donde se depositan los archivos de salida
	DIRTRANS=trans #c-El directorio donde se depositan las transacciones procesadass

	CONFIRMO_DIRECTORIOS=NO
}

verificarPermisosLogueo(){
	if ! [[ -r "$1" ]]; then
		name="$(obtenerNombreArchivo "$1")"
		loguear "Intentando setear permiso de lectura a $name" "INFO"
		echo "Seteando permiso de lectura a $name"
		chmod +r "$1"
		if ! [[ $? -eq 0 ]]; then
			loguear "No se puede setear permiso de lectura a $name" "ERR"
			echo "No se pudo setear permiso de lectura a $name"
			return 1
		fi
	fi
}


obtenerNombreArchivo(){
	echo "$(echo $1 | sed "s#.*/##")"
}

function loguear(){
	. $DIRLOGBIN/Loger.sh "Install" "$1" "$2"
}

loguearDirectoriosPorDefecto(){
	loguear "Directorio por defecto de Configuración: $DIRCONF " "INFO" #0
	loguear "Directorio por defecto de Ejecutables: $DIRBIN " "INFO" #a
	loguear "Directorio por defecto de Maestros y Tablas: $DIRMAE " "INFO" #b
	loguear "Directorio por defecto de Recepcion de Novedades: $DIRNOV " "INFO" #c
	loguear "Directorio por defecto de Archivos s: $DIROK " "INFO" #d
	loguear "Directorio por defecto de Archivos Rechazados: $DIRNOK " "INFO" #e
	loguear "Directorio por defecto de Archivos Procesados: $DIRPROC " "INFO" #f
	loguear "Directorio por defecto de Archivos de Salida: $DIROUT " "INFO" #g
	loguear "Directorio por defecto de Transacciones Procesadas: $DIRTRANS " "INFO" #h

}

function elegirDirectorios() {
	echo "Inicio del proceso de eleccion de directorios."
	loguear "Inicio del proceso de eleccion de directorios." "INFO"
	#a
	echo "Defina el directorio de ejecutables ($DIRBIN): "
	setearDirectorio DIRBIN
	directorios+=("$DIRBIN")
	loguear "El usuario eligio el nombre $DIRBIN para el directorio de ejecutables" "INFO"
	#b
	echo "Defina el directorio de Archivos Maestros ($DIRMAE): "
	setearDirectorio DIRMAE
	directorios+=("$DIRMAE")
	loguear "El usuario eligio el nombre $DIRMAE para el directorio de maestros y tablas" "INFO"
	#c
	echo "Defina el directorio de Archivos Aceptados ($DIROK): "
	setearDirectorio DIROK
	directorios+=("$DIROK")
	loguear "El usuario eligio el nombre $DIROK para el directorio de archivos aceptados, para luego ser procesados" "INFO"
	#d
	echo "Defina el directorio de rechazados ($DIRNOK): "
	setearDirectorio DIRNOK
	directorios+=("$DIRNOK")
	loguear "El usuario eligio el nombre $DIRNOK para el directorio de rechazados" "INFO"
	#e
	echo "Defina el directorio de Archivos Procesados ($DIRPROC): "
	setearDirectorio DIRPROC
	directorios+=("$DIRPROC")
	loguear "El usuario eligio el nombre $DIRPROC para el directorio de archivos ya procesados" "INFO"
	#f
	echo "Defina el directorio de Archivos de Salida ($DIROUT): "
	setearDirectorio DIROUT
	directorios+=("$DIROUT")
	loguear "El usuario eligio el nombre $DIROUT para el directorio de archivos de salida" "INFO"
	echo "Defina el directorio de Recepción de Transacciones ($DIRTRANS): "
	#g
	setearDirectorio DIRTRANS
	directorios+=("$DIRTRANS")
	loguear "El usuario eligio el nombre $DIRTRANS para el directorio de recepcion de transacciones" "INFO"
}

function setearDirectorio(){
	read respuesta
	if [[ $respuesta = "" ]] || ! esDirectorioValido "$respuesta"; then
		return 0
	fi
	eval "$1=\"$respuesta\""
}

function esDirectorioValido(){
	#NO puede haber dos directorios con el mismo nombre
	for i in "${directorios[@]}"; do
		if [ "$i" == "$1" ]; then
			loguear "Intento de utilizar el directorio $1 que no está disponible" "WAR"
			echo "$1 ya fue elegido para otro directorio, se usara el default."
			return 1	#es invalido
		fi
	done

	if esDirReservado "$1"; then
		return 1 #si es reservado, nombre invalido
	fi

	return 0 #es valido
}

function esDirReservado(){
	if [ "$1" == "$DIRCONF" ] || [ "$1" == "binarios" ] || [ "$1" == "datos" ]; then
		loguear "Intento de utilizar el directorio $1 que no está disponible" "WAR"
		echo "$1 es un nombre de directorio reservado, se usara el default."
		return 0 #verdadero, es un dir reservado
	fi
	return 1
}

function mostrarDirectoriosElegidos() {
	echo "Directorio elegido para los ejecutables: $DIRBIN"
	echo "Directorio elegido para Archivos Maestros: $DIRMAE"
	echo "Directorio elegido para Archivos Temporalmente Aceptados: $DIROK"
	echo "Directorio elegido para Archivos Rechazados: $DIRNOK"
	echo "Directorio elegido para Archivos Procesados: $DIRPROC"
	echo "Directorio elegido para Archivos de Salida: $DIROUT"
	echo "Directorio elegido para Transacciones Procesadas: $DIRTRANS"
}

function confirmarInstalacion() {

	answ=
	while [[ $answ = "" ]]; do
		echo "Desea continuar con la instalación? (Si – No)"
		loguear "Desea continuar con la instalacion?" "INFO"
		read answ
		answ=$(echo $answ | awk '{print tolower($0)}')
		loguear "El usuario responde: $answ" "INFO"

		if [[ $answ = "si" ]]; then
			CONFIRMO_DIRECTORIOS="Si"
		fi

		if [[ $answ = "no" ]]; then
			clear
		fi

	done
}

function grabarConfig() {
	echo "GRUPO-$GRUPO-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRCONF-$GRUPO/conf/-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRBIN-$GRUPO/$DIRBIN-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRMAE-$GRUPO/$DIRMAE-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIROK-$GRUPO/$DIROK-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRNOK-$GRUPO/$DIRNOK-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRPROC-$GRUPO/$DIRPROC-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIROUT-$GRUPO/$DIROUT-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRTRANS-$GRUPO/$DIRTRANS-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRNOV-$GRUPO/novedades-$USER-$(date '+%Y-%m-%d %H:%M:%S')
DIRLOG-$GRUPO/conf/log/-$USER-$(date '+%Y-%m-%d %H:%M:%S')" > $DIRCONF/tpconfig.txt
}

function creardirectorios() {
	echo "Creando estructuras de directorio"

	loguear "Actualizando la configuracion del sistema" "INFO"
	loguear "Creando estructuras de directorio..." "INFO"
	loguear "Instalacion CONCLUIDA" "INFO"

	loguear "Instalando programas y funciones" "INFO"

	loguear  "Directorio elegido para los Ejecutables: $(obtenerVariable DIRBIN)" "INFO"

	loguear "Directorio elegido para Archivos Maestros: $(obtenerVariable DIRMAE)" "INFO"

	loguear "Directorio elegido para Recepcion de Transacciones: $(obtenerVariable DIRTRANS)" "INFO"
	mkdir -p "$(obtenerVariable DIRTRANS)"

	loguear "Directorio elegido para Archivos Aceptados: $(obtenerVariable DIROK)" "INFO"
	mkdir -p "$(obtenerVariable DIROK)"

	loguear "Directorio elegido para Archivos Rechazados: $(obtenerVariable DIRNOK)" "INFO"
	mkdir -p "$(obtenerVariable DIRNOK)"

	loguear "Directorio elegido para Archivos de Salida: $(obtenerVariable DIROUT)" "INFO"
	mkdir -p "$(obtenerVariable DIROUT)"

	loguear "Directorio elegido para Archivos Procesados: $(obtenerVariable DIRPROC)" "INFO"
	mkdir -p "$(obtenerVariable DIRPROC)"

	loguear "Directorio elegido para Transacciones Procesadas: $(obtenerVariable DIRTRANS)" "INFO"
	mkdir -p "$(obtenerVariable DIRTRANS)"

	loguear "Grabando Archivos Novedades: $(obtenerVariable DIRNOV)" "INFO"
	mkdir -p "$(obtenerVariable DIRNOV)"
	cp -R Paquete/Lotes/*.csv "$(obtenerVariable DIRNOV)"

	loguear "Grabando Archivos Maestros: $(obtenerVariable DIRMAE)" "INFO"
	mkdir -p "$(obtenerVariable DIRMAE)"
	cp -R Paquete/CodigosISO8583.csv "$(obtenerVariable DIRMAE)"

	loguear "Grabando Archivos Ejecutables: $(obtenerVariable DIRBIN)" "INFO"
	cp -R Paquete/Binarios "$(obtenerVariable DIRBIN)"

}

function necesitaRepararse() {
	if [[ -d "$(obtenerVariable DIRTRANS)"  &&  -d "$(obtenerVariable DIROK)"  &&  -d "$(obtenerVariable DIRNOK)"  &&  -d "$(obtenerVariable DIROUT)"  &&  -d "$(obtenerVariable DIRPROC)"  &&   -d "$(obtenerVariable DIRMAE)"  &&   -d "$(obtenerVariable DIRBIN)" ]]; then
		echo "no"
	fi
	if ! [[ -d "$(obtenerVariable DIRTRANS)"  &&  -d "$(obtenerVariable DIROK)"  &&  -d "$(obtenerVariable DIRNOK)"  &&  -d "$(obtenerVariable DIROUT)"  &&  -d "$(obtenerVariable DIRPROC)"  &&   -d "$(obtenerVariable DIRMAE)"  &&   -d "$(obtenerVariable DIRBIN)" ]]; then
		echo "si"
	fi
}

function repararPrograma() {
	echo "Reparando instalacion."
	eliminarProgramaInstalado
	instalarPrograma
}

eliminarProgramaInstalado () {
	rm -d -rf $(ls | grep -v conf | grep -v bin | grep -v mae | grep -v Install.sh)
	rm $DIRCONF/tpconfig.txt
}

obtenerVariable(){
	echo $(grep $1 $DIRCONF/tpconfig.txt | cut -d '-' -f 2)
}

setearDireccionLoggerDefinitiva() {
	DIRLOGBIN="$(obtenerVariable DIRBIN)"
}

verificarPermisoLectura(){
	name="$(obtenerNombreArchivo "$1")"
	loguear "Intentando setear permiso de lectura a $name" "INFO"
	echo "Seteando permiso de lectura a $name"
	chmod +r-xw "$1"
	if ! [[ $? -eq 0 ]]; then
		echo "No se pudo setear permiso de lectura a $name"
		return 1
	fi
}

obtenerNombreArchivo(){
	echo "$(echo $1 | sed "s#.*/##")"
}

verificarPermisoEjecucion(){
	#Si no se puede leer > no se puede ejecutar
	verificarPermisoLectura "$1" || return 1
	name="$(obtenerNombreArchivo "$1")"
	loguear "Intentando setear permiso de ejecucion a $name" "INFO"
	echo "Intentando setear permiso de ejecucion a $name"
	chmod +x+r-w "$1"
	if ! [[ $? -eq 0 ]]; then
		loguear "No se puede setear permiso de ejecucion a $name" "ERR"
		echo "No se puede setear permiso de ejecucion a $name"
		return 1
	fi
}


main
