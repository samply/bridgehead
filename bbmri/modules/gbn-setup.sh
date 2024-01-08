#!/bin/bash

if [ "${ENABLE_GBN}" == "true" ]; then
	log INFO "GBN setup detected -- will start services for German Biobank Node."
	OVERRIDE+=" -f ./$PROJECT/modules/gbn-compose.yml"

	# The environment needs to be defined in /etc/bridgehead
	case "$ENVIRONMENT" in
		"production")
			ERIC_BROKER_ID=broker.bbmri.samply.de
			ERIC_ROOT_CERT=eric
			;;
		"test")
			ERIC_BROKER_ID=broker-test.bbmri-test.samply.de
			ERIC_ROOT_CERT=eric.test
			;;
		*)
			report_error 6 "Environment \"$ENVIRONMENT\" is unknown. Assuming production. FIX THIS!"
			ERIC_BROKER_ID=broker.bbmri.samply.de
			ERIC_ROOT_CERT=eric
			;;
	esac
	
	GBN_BROKER_URL=https://${GBN_BROKER_ID}
	GBN_PROXY_ID=${SITE_ID}.${GBN_BROKER_ID}
	GBN_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	GBN_SUPPORT_EMAIL=feedback@germanbiobanknode.de
fi
