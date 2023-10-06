#!/bin/bash

if [ -n "${ENABLE_DNPM}" ]; then
	log INFO "DNPM setup detected (Beam.Connect) -- will start Beam and Beam.Connect for DNPM."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-compose.yml"

	# Set variables required for Beam-Connect
	DNPM_APPLICATION_SECRET="$(echo \"This is a salt string to generate one consistent password for DNPM. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
	DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	DNPM_BROKER_ID="broker.ccp-it.dktk.dkfz.de"
	DNPM_BROKER_URL="https://${DNPM_BROKER_ID}"
	DNPM_PROXY_ID="${SITE_ID}.${DNPM_BROKER_ID}"
fi
