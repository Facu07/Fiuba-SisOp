#/bin/bash


#	INICIALIZAR AMBIENTE DESDE $GRUPO/bin/init.sh  
#	EL ARCHIVO DE CONFIGURACION $GRUPO/conf/tpconfig.txt
#--------------------------------------------------------------------------------
#	NOTAS:
#	Cuando este Script incia reliaza al inicializacion correctamente
#   	Exporta una variable de Ambiente TP_SISOP_INIT=YES


#--------------------------------------------------------------------------------
#	COMENTARIOS:
#	SCRIPTPATH -> Es el directorio desde donde se corre el Script
#
#	GRUPO: 		Directorio principal 
#	DIRBIN:		Directorio de Archivos binarios
#	DIRMAE:		Directorio de archvios Maestros
#	DIRNOV:		Directorio de Novedades
#	DIRNOK:		Directoiro de Archivos rechazados
#	DIRPROC:	Directorio de archivos a procesados
#	DIROUT:		Directorio de Archvos de salida
#	DIROK:		Directorio de Archivos de Aceptados
#	DIRCONF: 	Directorio de configuracion - GRUPO04/conf
#	DIRLOG: 	Directorio de archivos de LOG - GRUPO04/conf/log
#	DIRTRANS:	Directorio de Archivos de Transacciones




#---Listado de variables de ambiente
GRUPO=""
DIRBIN=""
DIRMAE=""
DIRNOV=""
DIRNOK=""
DIRPROC=""
DIROUT=""
DIROK=""
DIRCONF=""
DIRLOG=""
DIRTRANS=""


#
#Me muevo al directorio de inicio. -  GRUPO04
#Cargo los directorios fijos en sus variables de ambiente
findDirGrupo()
{
#--------Estado LIBERADO----------
	GRUPO="$( cd "$(dirname "$0")" ; cd .. ; pwd -P )"
	DIRLOG="$GRUPO/conf/log"
	DIRCONF="$GRUPO/conf"
	export GRUPO
	export DIRLOG
	export DIRCONF
	chmod +x glog.sh
	#./glog.sh "inicio" "Cargando variable $VARIABLE y ruta $VALOR... OK"

#echo $GRUPO
#echo $DIRLOG
#echo $DIRCONF

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
	unset GRUPO
	unset DIRCONF
	unset DIRLOG
	unset DIRBIN
	unset DIRMAE
	unset DIRNOV
	unset DIROK
	unset DIRNOK
	unset DIRPROC
	unset DIROUT
	unset DIRTRANS
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
				"GRUPO")
				GRUPO="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"DIRCONF")
				DIRCONF="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"DIRLOG")
				DIRLOG="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"DIRTRANS")
				DIRTRANS="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;		
				"DIRBIN")
				DIRBIN="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"DIRMAE")
				DIRMAE="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"DIRPROC")
				DIRPROC="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"DIRNOK")
				DIRNOK="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"DIRNOV")
				DIRNOV="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;	
				"DIROUT")
				DIROUT="$VALOR"
				VARCOUNT=$((VARCOUNT+1))
				;;
				"DIROK")
				DIROK="$VALOR"
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

	done <"$GRUPO/conf/tpconfig.txt"

#echo $GRUPO
#echo $DIRBIN
#echo $DIRMAE
#echo $NOVDIR
#echo $DIRNOK
#echo $DIRPROC
#echo $DIROUT
#echo $DIROK
#echo $DIRCONF
#echo $DIRLOG
#echo "Variable con nombre correctos: " $NOMBRECORRECTO
#echo "Todos los directorios existen: " $ALLDIREXISTS
}



verificarExistenTodasLasRutas()
{

	if [ "$ALLDIREXISTS" == "NO" ]
	then
		echo "Se han encontrado una o más rutas inexistentes para los directorios... ERROR"
		./glog.sh "inicio" "Se han encontrado una o más rutas inexistentes para los directorios." "ERROR"
		#inicializacionAbortadaMsj
		unsetVars
		return 0
	fi
}



exportarVariables()
{
	TP_SISOP_INIT=YES
	export TP_SISOP_INIT
	export GRUPO
	export DIRCONF
	export DIRLOG
	export DIRBIN
	export DIRMAE
	export DIRNOV
	export DIROK
	export DIRNOK
	export DIRPROC
	export DIROUT
	export DIRTRANS

	echo "Sistema inicializado con éxito. Se procede con la invocación del comando start para iniciar el proceso en segundo plano"
	echo "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
	./glog.sh "inicio" "====================== INICIALIZACION COMPLETADA CON EXITO ======================"
}

activarProceso()
{
	ps cax | grep "start.sh" > /dev/null

	if [ $? -eq 0 ]; 
	then
		echo "============ [ERROR] start.sh ya se encuentra en ejecución ============"
		./glog.sh "inicio" "No se pudo invocar el comando debido a que proc.sh ya se encuentra en ejecución" "ERROR"		
	else
		./start.sh &

		PID=$(ps | grep "start.sh" | cut -d' ' -f1)
		echo "============ Se inicia start.sh ID:$PID============"
		./glog.sh "inicio" "INFO: ============ Se inicia start.sh ID:$PID============"
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
		#inicializacionAbortadaMsj
		return 0
	else
		echo "El sistema no se encuentra inicializado..."
		./glog.sh "inicio" "El sistema no se encuentra inicializado."
	fi




	#verificarTpConfig
	#------------------Estado LIBERADO---------------------
	#--------------------------------------------------------------------------------------------------------#	
	#      VERIFICAR QUE EXISTA TPCONFIG.TXT Y TENGA PERMISO DE LECTURA       

	checkIfFileExists "$DIRCONF/tpconfig.txt"
		
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
		chmod +r "$DIRCONF/tpconfig.txt"

		checkIfFileIsReadable "$DIRCONF/tpconfig.txt"
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
		#inicializacionAbortadaMsj
		#unsetVars
		return 0
	fi

	#verificarTotalVar
	if [ "$VARCOUNT" != "11" ]
	then
		echo "Verificando cantidad esperada (11) y nombres de variables esperadas... ERROR"
		./glog.sh "inicio" "Verificando cantidad esperada (11) y nombres de variables esperadas." "ERROR"
		#inicializacionAbortadaMsj
		#unsetVars
		return 0
	else
		echo "Verificando cantidad esperada (11) y nombres de variables esperadas... OK"
		./glog.sh "inicio" "Verificando cantidad esperada (11) y nombres de variables esperadas... OK"
	fi

	#verificarMaePermisos
	fileExists="YES"
	checkIfFileExists "$DIRMAE/CodigosISO8583.csv"
	#checkIfFileExists "$DIRMAE/Operadores.txt"
	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos maestros en $DIRMAE... ERROR"
		./glog.sh "inicio" "Verificando existencia de los archivos maestros en $DIRMAE." "ERROR"
		#inicializacionAbortadaMsj
		#unsetVars
		return 0
	else
		echo "Verificando existencia de los archivos maestros en $DIRMAE... OK"
		./glog.sh "inicio" "INFO: Verificando existencia de los archivos maestros en $DIRMAE... OK"
		echo "Seteando permisos de lectura a los archivos maestros... OK"
		./glog.sh "inicio" "Seteando permisos de lectura a los archivos maestros... OK"
		chmod +r "$DIRMAE/CodigosISO8583.csv"
		#chmod +r "$MAESTROSDIR/Sucursales.txt"

		fileReadable="YES"
		checkIfFileIsReadable "$DIRMAE/CodigosISO8583.csv"
		#checkIfFileIsReadable "$MAESTROSDIR/Sucursales.txt"
		if [ "$fileReadable" == "NO" ]
		then
			echo "Verificando que los archivos maestros tengan permiso de lectura... ERROR"
			./glog.sh "inicio" "Verificando que los archivos maestros tengan permiso de lectura." "ERROR"
			#inicializacionAbortadaMsj
			#unsetVars
			return 0
		else
			echo "Verificando que los archivos maestros tengan permiso de lectura... OK"
			./glog.sh "inicio" "Verificando que los archivos maestros tengan permiso de lectura... OK"
		fi
	fi

	#verificarEjecPermisos
	fileExists="YES"
	checkIfFileExists "$DIRBIN/glog.sh"
	checkIfFileExists "$DIRBIN/start.sh"
	checkIfFileExists "$DIRBIN/stop.sh"
	checkIfFileExists "$DIRBIN/proc.sh"

	if [ "$fileExists" == "NO" ]
	then
		echo "Verificando existencia de los archivos ejecutables en $DIRBIN... ERROR"
		./glog.sh "inicio" "Verificando existencia de los archivos ejecutables en $DIRBIN." "ERROR"
		#inicializacionAbortadaMsj
		#unsetVars
		echo "retornanado......"
		return 0
	else
		echo "Verificando existencia de los archivos ejecutables en $DIRBIN... OK"
		./glog.sh "inicio" "Verificando existencia de los archivos ejecutables en $DIRBIN... OK"
	
		echo "Seteando permisos de ejecución a los archivos ejecutables... OK"
		./glog.sh "inicio" "Seteando permisos de ejecución a los archivos ejecutables... OK"
	
		chmod +x "$DIRBIN/Loger.sh"
		chmod +x "$DIRBIN/glog.sh"
		chmod +x "$DIRBIN/inicio.sh"
		chmod +x "$DIRBIN/proc.sh"
		chmod +x "$DIRBIN/start.sh"
		chmod +x "$DIRBIN/stop.sh"

		fileExecutable="YES"
		checkIfFileIsExecutable "$DIRBIN/Loger.sh"
		checkIfFileIsExecutable "$DIRBIN/glog.sh"
		checkIfFileIsExecutable "$DIRBIN/inicio.sh"
		checkIfFileIsExecutable "$DIRBIN/proc.sh"
		checkIfFileIsExecutable "$DIRBIN/start.sh"
		checkIfFileIsExecutable "$DIRBIN/stop.sh"
		
		if [ "$fileExecutable" == "NO" ]
		then
			echo "Verificando que los archivos ejecutables tengan permiso de ejecución... ERROR"
			./glog.sh "inicio" "Verificando que los archivos ejecutables tengan permiso de ejecución." "ERROR"
			#inicializacionAbortadaMsj
			#unsetVars
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

	 
