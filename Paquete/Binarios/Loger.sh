#!/bin/bash

	if [ $# -lt 2 -o $# -gt 3 ]; then
		echo "Cantidad de parámetros inválida"
	else
		WHEN=`date`
		WHO=`whoami`
		WHERE=$1
		if [ $# -eq 3 ]; then
			if [ $3 == 'INFO' -o $3 == 'WAR' -o $3 == 'ERR' ]; then
				WHAT=$3
			else
				WHAT='INFO'
			fi
		else
			WHAT='INFO'
		fi
		WHY=$2
		Separador="="
		Linea="[$WHEN] $Separador [$WHO] $Separador [$WHERE] $Separador [$WHAT] $Separador $WHY"
		LOG_DIR="$DIRLOG/$WHERE.log"

		if [ -f "$LOG_DIR" ]; then
			echo $Linea>>"$LOG_DIR"
		else
			echo $Linea>$LOG_DIR
		fi

	fi
