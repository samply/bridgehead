#!/bin/bash

function dnpmSetup() {
	if [ -e /etc/bridgehead/dnpm/local_targets.json ]; then
		log INFO "DNPM setup detected (Beam.Connect) -- will start Beam.Connect for DNPM."
		OVERRIDE+=" -f ./dnpm/dnpm-compose-beamconnect.yml"
		DNPM_APPLICATION_SECRET="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
		DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
		source /etc/bridgehead/dnpm/shared-but-secret-vars || fail_and_report 1 "Unable to load /etc/bridgehead/dnpm/shared-but-secret-vars"
		export DNPM_DISCOVERY_URL
		if [ -e /etc/bridgehead/dnpm/bwhcConnectorConfig.xml ]; then
			log INFO "DNPM setup detected (with Frontend/Backend) -- will start BWHC Frontend/Backend."
			OVERRIDE+=" -f ./dnpm/dnpm-compose-bwhc.yml"
		fi
	fi
}
