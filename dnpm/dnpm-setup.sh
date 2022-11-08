#!/bin/bash

function dnpmSetup() {
	if [ -e /etc/bridgehead/dnpm/local_targets.json ]; then
		log INFO "DNPM setup detected -- will start DNPM Connector."
		source /etc/bridgehead/dnpm/shared-but-secret-vars || fail_and_report 1 "Unable to load /etc/bridgehead/dnpm/shared-but-secret-vars"
		OVERRIDE+="-f ./dnpm/dnpm-compose.yml"
		DNPM_APPLICATION_SECRET="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
		DNPM_BEAM_SECRET_SHORT="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
	fi
}
