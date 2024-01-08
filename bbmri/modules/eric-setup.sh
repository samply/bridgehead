#!/bin/bash

if [ "${ENABLE_ERIC}" == "true" ]; then
	log INFO "BBMRI-ERIC setup detected -- will start services for BBMRI-ERIC."
	OVERRIDE+=" -f ./$PROJECT/modules/eric-compose.yml"

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

	ERIC_BROKER_URL=https://${ERIC_BROKER_ID}
	ERIC_PROXY_ID=${SITE_ID}.${ERIC_BROKER_ID}
	ERIC_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	ERIC_SUPPORT_EMAIL=bridgehead@helpdesk.bbmri-eric.eu
fi
