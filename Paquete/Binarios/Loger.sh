#!/bin/bash
	MAX_LOG_SIZE=2000
	LOG_DEFAULT_LONG=10
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
			CURRENT_LOG_SIZE=`du -k $LOG_DIR --block-size=K | cut -f1 | sed 's|[^0-9]||g'`
			if [ "$CURRENT_LOG_SIZE" -ge "$MAX_LOG_SIZE" ]; then
				LAST_LINES=$(tail -n $LOG_DEFAULT_LONG $LOG_DIR)
				echo "${LAST_LINES}" > $LOG_DIR
				echo "Log exedido">>"$LOG_DIR"
			fi
			echo $Linea>>"$LOG_DIR"
		else
			echo $Linea>$LOG_DIR
		fi

	fi
