#!/bin/bash

function idManagementSetup() {
	if [ -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
		log INFO "id-management setup detected -- will start id-management (mainzelliste & magicpl)."
		OVERRIDE+=" -f ./$PROJECT/modules/id-management-compose.yml"

		# Auto Generate local Passwords
		PATIENTLIST_POSTGRES_PASSWORD="$(echo \"This is a salt string to generate one consistent password. It is not required to be secret.\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
		IDMANAGER_LOCAL_PATIENTLIST_APIKEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"

		# Source the ID Generators Configuration
		source /etc/bridgehead/patientlist-id-generators.env

		# Ensure old ids are working !!!
		legacyIdMapping
	fi

}

# TODO: Map all old site ids to the new ones
function legacyIdMapping() {
    case ${SITE_ID} in
	"berlin")
		export IDMANAGEMENT_FRIENDLY_ID=Berlin
		;;
	"dresden")
		export IDMANAGEMENT_FRIENDLY_ID=Dresden
		;;
	"frankfurt")
		export IDMANAGEMENT_FRIENDLY_ID=Frankfurt
		;;
	*)
		export IDMANAGEMENT_FRIENDLY_ID=$SITE_ID
		;;
    esac
}
