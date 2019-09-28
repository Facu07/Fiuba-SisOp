#/bin/bash


#	INICIALIZAR AMBIENTE DESDE $GRUPODIR/bin/init.sh  
#	EL ARCHIVO DE CONFIGURACION $GRUPODIR/conf/tpconfig.txt
#--------------------------------------------------------------------------------
#	NOTAS:
#	Cuando este Script incia reliaza al inicializacion correctamente
#   	Exporta una variable de Ambiente TP_SISOP_INIT=YES


#--------------------------------------------------------------------------------
#	COMENTARIOS:
#	SCRIPTPATH -> Es el directorio desde donde se corre el Script
#
#	GRUPODIR: 	Directorio principal 
#	BINDIR:		Directorio de Archivos binarios
#	MAEDIR:		Directorio de archvios Maestros
#	NOVDIR:		Directorio de Novedades
#	RECHDIR:	Directoiro de Archivos rechazados
#	PROCDIR:	Directorio de archivos a procesar y aceptados
#	SALDIR:		Directorio de Archvos de salida
#	ARRDIR:		Directorio de Archivos de Arribo
#	CONFDIR: 	Directorio de configuracion - GRUPO04/conf
#	LOGDIR: 	Directorio de archivos de LOG - GRUPO04/conf/log




#---Listado de variables de ambiente
GRUPODIR=""
BINDIR=""
MAEDIR=""
NOVDIR=""
RECHDIR=""
PROCDIR=""
SALDIR=""
ACEPDIR=""
CONFDIR=""
LOGDIR=""


#
#Me muevo al directorio de inicio. -  GRUPO04
#Cargo los directorios fijos en sus variables de ambiente
findDirGrupo()
{
#--------Estado LIBERADO----------
	GRUPODIR="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )"
	LOGDIR="$GRUPODIR/conf/log"
	CONFDIR="$GRUPODIR/conf"
	export GRUPODIR
	export LOGDIR
	export CONFDIR
	chmod +x glog.sh
	#./glog.sh "inicio" "Cargando variable $VARIABLE y ruta $VALOR... OK"

#echo $GRUPODIR
#echo $LOGDIR
#echo $CONFDIR

}


checkIfFileExists()
{
	./glog.sh "inicio" "Verificando que el archivo $FILE existe..."
	fileExists="YES"
	FILE=$1
	if [ ! -f "$FILE" ]
	then
		fileExists="NO"
	fi
}

checkIfFileIsReadable()
{
	./glog.sh "inicio" "Verificando que el archivo $FILE tenga permisos de Lectura..."	
	fileReadable="YES"
	FILE=$1
	if [ ! -r "$FILE" ]
	then
		fileReadable="NO"
	fi
}


checkIfFileIsExecutable()
{
	./glog.sh "inicio" "Verificando que el archivo $FILE tenga permisos de ejecucion..."
	fileExecutable="YES"
	FILE=$1
	if [ ! -x "$FILE" ]
	then
		fileExecutable="NO"
	fi
}


unsetVars()
{
	./glog.sh "inicio" "unset variables de ambiente..."
	unset TP_SISOP_INIT
	unset GRUPODIR
	unset CONFDIR
	unset LOGDIR
	unset BINDIR
	unset MAEDIR
	unset NOVDIR
	unset ACEPDIR
	unset RECHDIR
	unset PROCDIR
	unset SALDIR
}



#----------------------------------------------------------------------------------------------------------
#	Leo las variables del archivo tpconfig.txt
readTpconfig()
{
	./glog.sh "inicio" "leyendo archvio tpconfgi.txt....."
	VARCOUNT=0	
	ALLDIREXISTS="YES"
	while read REGISTRO
	do	
		VARIABLE=$(cut -d'-' -f1 <<<$REGISTRO)
		VALOR=$(cut -d'-' -f2 <<<$REGISTRO)

		#echo $VARIABLE
		#echo $VALOR

		NOMBRECORRECTO="YES"

		#tengo que chequear que todas las variables esten inicializadas....
		#para eso era el conteo de las mismas

		if [ ! -d "$VALOR" ]	
		then
			echo "Cargando variable $VARIABLE y ruta $VALOR... ERROR - RUTA INEXISTENTE"
			./glog.sh "inicio" "Cargando variable $VARIABLE y ruta $VALOR... ERROR - RUTA INEXISTENTE"
			ALLDIREXISTS="NO"
 		else
			case $VARIABLE in
				"GRUPODIR")
				GRUPODIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"CONFDIR")
				CONFDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"LOGDIR")
				LOGDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"BINDIR")
				BINDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"MAEDIR")
				MAEDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"PROCDIR")
				PROCDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"RECHDIR")
				RECHDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"NOVDIR")
				PROCDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"SALDIR")
				SALDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"ACEPDIR")
				NOVDIR="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				
				*)
				NOMBRECORRECTO="NO"
				;;		
			esac
			
			if [ "$NOMBRECORRECTO" == "NO" ]
			then
				echo "Cargando variable $VARIABLE y ruta $VALOR... ERROR - NOMBRE INCORRECTO"
				./glog.sh "inicio" "Cargando variable $VARIABLE y ruta $VALOR... ERROR - NOMBRE INCORRECTO"
				
			else
				echo "Cargando variable $VARIABLE y ruta $VALOR... OK"
				./glog.sh "inicio" "Cargando variable $VARIABLE y ruta $VALOR... OK"
			fi
		fi	

	done <"$GRUPODIR/conf/tpconfig.txt"

#echo $GRUPODIR
#echo $BINDIR
#echo $MAEDIR
#echo $NOVDIR
#echo $RECHDIR
#echo $PROCDIR
#echo $SALDIR
#echo $ACEPDIR
#echo $CONFDIR
#echo $LOGDIR
#echo "Variable con nombre correctos: " $NOMBRECORRECTO
#echo "Todos los directorios existen: " $ALLDIREXISTS
}



verificarExistenTodasLasRutas()
{

	if [ "$ALLDIREXISTS" == "NO" ]
	then
		echo "Se han encontrado una o más rutas inexistentes para los directorios... ERROR"
		./glog.sh "inicio" "Se han encontrado una o más rutas inexistentes para los directorios." "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	fi
}



exportarVariables()
{
	TP_SISOP_INIT=YES
	export TP_SISOP_INIT
	export GRUPODIR
	export CONFDIR
	export LOGDIR
	export BINDIR
	export MAESTROSDIR
	export ARRIBOSDIR
	export ACEPTADOSDIR
	export RECHAZADOSDIR
	export PROCESADOSDIR
	export SALIDADIR

	echo "Sistema inicializado con éxito. Se procede con la invocación del comando start para iniciar el proceso en segundo plano"
	echo "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
	./glog.sh "inicio" "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
}

activarProceso()
{
	ps cax | grep "proceso.sh" > /dev/null

	if [ $? -eq 0 ]; 
	then
		echo "============ [ERROR] proceso.sh ya se encuentra en ejecución ============"
		"$BINDIR"/glog.sh "iniicio" "No se pudo invocar el comando debido a que proceso.sh ya se encuentra en ejecución" "ERROR"		
	else
		"$BINDIR"/proc.sh &

		PID=$(ps | grep "proc.sh" | cut -d' ' -f1)
		echo "============ Se inicia proceso.sh ID:$PID============"
		"$BINDIR"/glog.sh "iniicio" "INFO: ============ Se inicia proc.sh ID:$PID============"
	fi
}


init()
{
	findDirGrupo

	echo "Corriendo Scripts de Inicializacion..."	
	./glog.sh "inicio" "Corriendo Scripts de Inicializacion..."
	
	#verificarSiEstaIniciado
	#--------------------------------------------------------------------------------------------------------#	
	#      VERIFICAR QUE EL SISTEMA NO ESTE INICIADO	       

	echo "Verificando que el sistema no se encuentre inicializado..."	
	./glog.sh "inicio" "Verificando que el sistema no se encuentre inicializado.."

	if [ "$TP_SISOP_INIT" == "YES" ] 
	then
		echo "El sistema ya se encuentra  inicializado."
		./glog.sh "inicio" "WARNING: El sistema ya se encuentra inicializado."
		inicializacionAbortadaMsj
		return 0
	else
		echo "El sistema no se encuentra inicializado..."
		./glog.sh "inicio" "El sistema no se encuentra inicializado."
	fi




	#verificarTpConfig
	#------------------Estado LIBERADO---------------------
	#--------------------------------------------------------------------------------------------------------#	
	#      VERIFICAR QUE EXISTA TPCONFIG.TXT Y TENGA PERMISO DE LECTURA       

	checkIfFileExists "$CONFDIR/tpconfig.txt"
		
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia del archivo de configuración... ERROR"
		./glog.sh "inicio" "Verificando existencia del archivo de configuración." "ERROR"
		#inicializacionAbortadaMsj "MsjAbortConfNoE"
		return 0
	else
		echo "Verificando existencia del archivo de configuración... OK"
		./glog.sh "inicio" "Verificando existencia del archivo de configuración... OK"
	
		echo "Setando permiso de lectura al archivo de configuración... OK"
		./glog.sh "inicio" "Setando permiso de lectura al archivo de configuración... OK"
		chmod +r "$CONFDIR/tpconfig.txt"

		checkIfFileIsReadable "$CONFDIR/tpconfig.txt"
		if [ "$fileReadable" == "NO" ]
		then
			echo "Verificando que el archivo de configuración tenga permisos de lectura... ERROR"
			./glog.sh "inicio" "Verificando que el archivo de configuración tenga permisos de lectura." "ERROR"
			#inicializacionAbortadaMsj "MsjAbortConfNoRead"
			return 0
		else
			echo "Verificando que el archivo de configuración tenga permisos de lectura... OK"
			./glog.sh "inicio" "Verificando que el archivo de configuración tenga permisos de lectura... OK"
		fi
	fi

	readTpconfig

	#verificarExistenTodasLasRutas
	if [ "$ALLDIREXISTS" == "NO" ]
	then
		echo "Se han encontrado una o más rutas inexistentes para los directorios... ERROR"
		./glog.sh "inicio" "Se han encontrado una o más rutas inexistentes para los directorios." "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	fi

	#verificarTotalVar
	if [ "$VARCOUNT" != "10" ]
	then
		echo "Verificando cantidad esperada (10) y nombres de variables esperadas... ERROR"
		./glog.sh "inicio" "Verificando cantidad esperada (10) y nombres de variables esperadas." "ERROR"
		inicializacionAbortadaMsj
		unsetVars
		return 0
	else
		echo "Verificando cantidad esperada (10) y nombres de variables esperadas... OK"
		./glog.sh "inicio" "Verificando cantidad esperada (10) y nombres de variables esperadas... OK"
	fi

	#verificarMaePermisos
	fileExists="YES"
	checkIfFileExists "$MAEDIR/CodigosISO8583.txt"
	#checkIfFileExists "$MAEDIR/Operadores.txt"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos maestros en $MAEDIR... ERROR"
		./glog.sh "inicio" "Verificando existencia de los archivos maestros en $MAEDIR." "ERROR"
		#inicializacionAbortadaMsj
		unsetVars
		return 0
	else
		echo "Verificando existencia de los archivos maestros en $MAESTROSDIR... OK"
		./glog.sh "inicio" "INFO: Verificando existencia de los archivos maestros en $MAESTROSDIR... OK"
		echo "Seteando permisos de lectura a los archivos maestros... OK"
		./glog.sh "inicio" "Seteando permisos de lectura a los archivos maestros... OK"
		chmod +r "$MAEDIR/CodigosISO8583.txt"
		#chmod +r "$MAESTROSDIR/Sucursales.txt"

		fileReadable="YES"
		checkIfFileIsReadable "$MAEDIR/CodigosISO8583.txt"
		#checkIfFileIsReadable "$MAESTROSDIR/Sucursales.txt"
		if [ "$fileReadable" == "NO" ]
		then
			echo "Verificando que los archivos maestros tengan permiso de lectura... ERROR"
			./glog.sh "inicio" "Verificando que los archivos maestros tengan permiso de lectura." "ERROR"
			#inicializacionAbortadaMsj
			unsetVars
			return 0
		else
			echo "Verificando que los archivos maestros tengan permiso de lectura... OK"
			./glog.sh "inicio" "Verificando que los archivos maestros tengan permiso de lectura... OK"
		fi
	fi

	#verificarEjecPermisos
	fileExists="YES"
	checkIfFileExists "$BINDIR/mover"
	checkIfFileExists "$BINDIR/glog"
	checkIfFileExists "$BINDIR/start"
	checkIfFileExists "$BINDIR/stop"
	checkIfFileExists "$BINDIR/proceso.sh"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos ejecutables en $BINDIR... ERROR"
		./glog.sh "inicio" "Verificando existencia de los archivos ejecutables en $BINDIR." "ERROR"
		#inicializacionAbortadaMsj
		unsetVars
		echo "retornanado......"
		return 0
	else
		echo "Verificando existencia de los archivos ejecutables en $BINDIR... OK"
		./glog.sh "inicio" "Verificando existencia de los archivos ejecutables en $BINDIR... OK"
	
		echo "Seteando permisos de ejecución a los archivos ejecutables... OK"
		./glog.sh "inicio" "Seteando permisos de ejecución a los archivos ejecutables... OK"
	
		chmod +x "$BINDIR/loger.sh"
		chmod +x "$BINDIR/glog.sh"
		chmod +x "$BINDIR/inicio.sh"
		chmod +x "$BINDIR/proc.sh"
		chmod +x "$BINDIR/start.sh"
		chmod +x "$BINDIR/stop.sh"
		chmod +x "$BINDIR/validacion_archivos.sh"

		fileExecutable="YES"
		checkIfFileIsExecutable "$BINDIR/loger.sh"
		checkIfFileIsExecutable "$BINDIR/glog.sh"
		checkIfFileIsExecutable "$BINDIR/inicio.sh"
		checkIfFileIsExecutable "$BINDIR/proc.sh"
		checkIfFileIsExecutable "$BINDIR/start.sh"
		checkIfFileIsExecutable "$BINDIR/stop.sh"
		checkIfFileIsExecutable "$BINDIR/validacion_archivos.sh"
		if [ "$fileExecutable" == "NO" ]
		then
			echo "Verificando que los archivos ejecutables tengan permiso de ejecución... ERROR"
			./glog.sh "inicio" "Verificando que los archivos ejecutables tengan permiso de ejecución." "ERROR"
			#inicializacionAbortadaMsj
			unsetVars
			return 0
		else
			echo "Verificando que los archivos ejecutables tengan permiso de ejecución... OK"
			./glog.sh "inicio" "Verificando que los archivos ejecutables tengan permiso de ejecución... OK"
		fi
	fi

	exportarVariables

	activarProceso
}



init

	 
