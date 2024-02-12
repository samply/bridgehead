#!/bin/bash

if [ "${ENABLE_EHDS2}" == "true" ]; then
	log INFO "EHDS2 setup detected -- will start services for German Biobank Node."
	OVERRIDE+=" -f ./$PROJECT/modules/ehds2-compose.yml"

	# The environment needs to be defined in /etc/bridgehead
	case "$ENVIRONMENT" in
		"production")
			export EHDS2_BROKER_ID=broker.bbmri.samply.de
			export EHDS2_ROOT_CERT=ehds2
			;;
		"test")
			export EHDS2_BROKER_ID=broker.test.bbmri.samply.de
			export EHDS2_ROOT_CERT=ehds2.test
			;;
		*)
			report_error 6 "Environment \"$ENVIRONMENT\" is unknown. Assuming production. FIX THIS!"
			export EHDS2_BROKER_ID=broker.bbmri.samply.de
			export EHDS2_ROOT_CERT=ehds2
			;;
	esac
	
	EHDS2_BROKER_URL=https://${EHDS2_BROKER_ID}
	EHDS2_PROXY_ID=${SITE_ID}.${EHDS2_BROKER_ID}
	EHDS2_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	EHDS2_SUPPORT_EMAIL=feedback@germanbiobanknode.de
fi
