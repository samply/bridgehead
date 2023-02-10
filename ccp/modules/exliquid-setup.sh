#!/bin/bash

function exliquidSetup() {
	case ${SITE_ID} in
		berlin|dresden|essen|frankfurt|freiburg|luebeck|mainz|muenchen-lmu|muenchen-tu|mannheim|tuebingen)
			EXLIQUID=1
			;;
		dktk-test)
			EXLIQUID=1
			;;
		*)
			EXLIQUID=0
			;;
	esac
	if [[ $EXLIQUID -eq 1 ]]; then
		log INFO "EXLIQUID setup detected -- will start Report-Hub."
		OVERRIDE+=" -f ./$PROJECT/modules/exliquid-compose.yml"
	fi
}
