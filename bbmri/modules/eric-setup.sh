#!/bin/bash

if [ "${ENABLE_ERIC}" == "true" ]; then
	log INFO "BBMRI-ERIC setup detected -- will start services for BBMRI-ERIC."
	OVERRIDE+=" -f ./$PROJECT/modules/eric-compose.yml"

	# The environment needs to be defined in /etc/bridgehead
	case "$ENVIRONMENT" in
		"production")
			export ERIC_BROKER_ID=broker.bbmri.samply.de
			export ERIC_ROOT_CERT=eric
			;;
		"acceptance")
			export ERIC_BROKER_ID=broker-acc.bbmri-acc.samply.de
			export ERIC_ROOT_CERT=eric.acc
			;;
		"test")
			export ERIC_BROKER_ID=broker-test.bbmri-test.samply.de
			export ERIC_ROOT_CERT=eric.test
			;;
		*)
			report_error 6 "Environment \"$ENVIRONMENT\" is unknown. Assuming production. FIX THIS!"
			export ERIC_BROKER_ID=broker.bbmri.samply.de
			export ERIC_ROOT_CERT=eric
			;;
	esac

	ERIC_BROKER_URL=https://${ERIC_BROKER_ID}
	ERIC_PROXY_ID=${SITE_ID}.${ERIC_BROKER_ID}
	ERIC_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	ERIC_SUPPORT_EMAIL=bridgehead@helpdesk.bbmri-eric.eu

	#Monitoring
	ERIC_MONITORING_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
fi
