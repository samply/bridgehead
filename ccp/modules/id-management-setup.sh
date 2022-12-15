#!/bin/bash

function idManagementSetup() {
	if [ -n "$ENABLE_ID_MANAGEMENT" ]; then
		log INFO "id-management setup detected -- will start id-management (mainzelliste & magicpl)."
		OVERRIDE+=" -f ./$PROJECT/modules/id-management-compose.yml"

		# Auto Generate local Passwords
		PATIENTLIST_POSTGRES_PASSWORD="$(echo \"id-management-module-db-password-salt\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
		IDMANAGER_LOCAL_PATIENTLIST_APIKEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"

		# Transform Seeds Configuration to pass it to the Mainzelliste Container
		PATIENTLIST_SEEDS_TRANSFORMED="$(declare -p PATIENTLIST_SEEDS | tr -d '\"' | sed 's/\[/\[\"/g' | sed 's/\]/\"\]/g')"

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
