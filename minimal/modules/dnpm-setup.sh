#!/bin/bash

if [ -n "${ENABLE_DNPM}" ]; then
	log DEBUG "DNPM setup detected (Beam.Connect) -- will start Beam and Beam.Connect for DNPM."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-compose.yml"

	# Set variables required for Beam-Connect
	DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	DNPM_BROKER_ID="broker.ccp-it.dktk.dkfz.de"
	DNPM_BROKER_URL="https://${DNPM_BROKER_ID}"
	if [ -z ${BROKER_URL_FOR_PREREQ+x} ]; then
		BROKER_URL_FOR_PREREQ=$DNPM_BROKER_URL
		log DEBUG "No Broker for clock check set; using $DNPM_BROKER_URL"
	fi
	DNPM_PROXY_ID="${SITE_ID}.${DNPM_BROKER_ID}"
fi
