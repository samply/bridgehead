#!/bin/bash
##nNGM vars:
#NNGM_MAGICPL_APIKEY
#NNGM_CTS_APIKEY
#NNGM_CRYPTKEY

function nngmSetup() {
	if [ -n "$NNGM_CTS_APIKEY" ]; then
		log INFO "nNGM setup detected -- will start nNGM Connector."
		OVERRIDE+=" -f ./$PROJECT/nngm-compose.yml"
	fi
	}

function mtbaSetup() {
	# TODO: Check if ID-Management Module is activated!
	if [ -n "$ENABLE_MTBA" ];then
		log INFO "MTBA setup detected -- will start MTBA Service and CBioPortal."
		if [ ! -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
			log ERROR "Detected MTBA Module configuration but ID-Management Module seems not to be configured!"
			exit 1;
		fi
		OVERRIDE+=" -f ./$PROJECT/mtba-compose.yml"
	fi
}
