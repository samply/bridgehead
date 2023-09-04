#!/bin/bash

if [ "${ENABLE_GBN}" == "true" ]; then
	log INFO "GBN setup detected -- will start services for German Biobank Node."
	OVERRIDE+=" -f ./$PROJECT/modules/gbn-compose.yml"

	# Set required variables
	GBN_BROKER_ID=broker.bbmri.de
	GBN_BROKER_URL=https://${GBN_BROKER_ID}
	GBN_PROXY_ID=${SITE_ID}.${GBN_BROKER_ID}
	GBN_FOCUS_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	GBN_SUPPORT_EMAIL=bridgehead@helpdesk.bbmri-eric.eu
fi
