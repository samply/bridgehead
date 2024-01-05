#!/bin/bash

if [ "${ENABLE_ERIC}" == "true" ]; then
	log INFO "BBMRI-ERIC setup detected -- will start services for BBMRI-ERIC."
	OVERRIDE+=" -f ./$PROJECT/modules/eric-compose.yml"

	# Set required variables
	ERIC_BROKER_ID=broker.bbmri.samply.de
	ERIC_ROOT_CERT=eric

	if [ "{$ENABLE_TEST}" == "true" ]; then
		ERIC_BROKER_ID=broker-test.bbmri-test.samply.de
		ERIC_ROOT_CERT=eric.test
	fi
	
	ERIC_BROKER_URL=https://${ERIC_BROKER_ID}
	ERIC_PROXY_ID=${SITE_ID}.${ERIC_BROKER_ID}
	ERIC_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	ERIC_SUPPORT_EMAIL=bridgehead@helpdesk.bbmri-eric.eu
fi
