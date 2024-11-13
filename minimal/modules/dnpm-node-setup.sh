#!/bin/bash

if [ -n "${ENABLE_DNPM_NODE}" ]; then
	log INFO "DNPM setup detected -- will start DNPM:DIP node."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-node-compose.yml"

	# Set variables required for BwHC Node. ZPM_SITE is assumed to be set in /etc/bridgehead/<project>.conf
	if [ -z "${ZPM_SITE+x}" ]; then
		log ERROR "Mandatory variable ZPM_SITE not defined!"
		exit 1
	fi
	DNPM_SYNTH_NUM=${DNPM_SYNTH_NUM:--1}
    DNPM_MYSQL_ROOT_PASSWORD="$(generate_simple_password 'dnpm mysql')"
    DNPM_AUTHUP_SECRET="$(generate_simple_password 'dnpm authup')"
fi
