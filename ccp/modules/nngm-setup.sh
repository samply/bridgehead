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
