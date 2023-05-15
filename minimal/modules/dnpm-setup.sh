#!/bin/bash

if [ -n "${ENABLE_DNPM}" ]; then
	log INFO "DNPM setup detected (Beam.Connect) -- will start Beam.Connect for DNPM."
	OVERRIDE+=" -f ./$PROJECT/modules/dnpm-compose-beamconnect.yml"

	# Set variables required for Beam-Connect
	DNPM_APPLICATION_SECRET="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
	DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	DNPM_BROKER_ID="broker.dev.ccp-it.dktk.dkfz.de"
	DNPM_BROKER_URL="https://${DNPM_BROKER_ID}"
	DNPM_PROXY_ID="${SITE_ID}.${DNPM_BROKER_ID}"

	# Optionally, start bwhc as well. This is currently only experimental
	if [ -n "${ENABLE_DNPM_BWHC}" ]; then
		log INFO "DNPM setup detected (with Frontend/Backend) -- will start BWHC Frontend/Backend. This is highly experimental!"
		OVERRIDE+=" -f ./$PROJECT/modules/dnpm-compose-bwhc.yml"
	fi
fi
