#!/bin/bash

function idManagementSetup() {
	if [ -n "$ENABLE_ID_MANAGEMENT" ]; then
		log INFO "id-management setup detected -- will start id-management (mainzelliste & magicpl)."
		OVERRIDE+=" -f ./$PROJECT/modules/id-management-compose.yml"

		# Auto Generate local Passwords
		PATIENTLIST_POSTGRES_PASSWORD="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
		IDMANAGER_LOCAL_PATIENTLIST_APIKEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"

		# Source the ID Generators Configuration
		source /etc/bridgehead/patientlist-id-generators.env
		log INFO "ID-Management Generator 1: ${ML_BK_IDGENERATOR_RANDOM_1}"
	fi

}
