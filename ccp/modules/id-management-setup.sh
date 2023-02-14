#!/bin/bash


# Transform into single string array, e.g. 'dktk-test' to 'dktk test'
# Usage: transformToSingleStringArray 'dktk-test' -> 'dktk test'
function transformToSingleStringArray() {
	echo "${1//-/ }";
}

# Ensure all Words are Uppercase
# Usage: transformToUppercase 'dktk test' -> 'Dktk Test'
function transformToUppercase() {
	result="";
	for word in $1; do
		result+=" ${word^}";
	done
	echo "$result";
}

# Handle all execeptions from the norm (e.g LMU, TUM)
# Usage: applySpecialCases 'Muenchen Lmu Test' -> 'Muenchen LMU Test'
function applySpecialCases() {
	result="$1";
	result="${result/Lmu/LMU}";
	result="${result/Tum/TUM}";
	echo "$result";
}

# Transform current siteids to legacy version
# Usage: legacyIdMapping "dktk-test" -> "DktkTest"
function legacyIdMapping() {
	single_string_array=$(transformToSingleStringArray "$1");
	uppercase_string=$(transformToUppercase "$single_string_array");
	normalized_string=$(applySpecialCases "$uppercase_string");
	echo "$normalized_string" | tr -d ' '
}

if [ -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
  log INFO "id-management setup detected -- will start id-management (mainzelliste & magicpl)."
  OVERRIDE+=" -f ./$PROJECT/modules/id-management-compose.yml"

  # Auto Generate local Passwords
  PATIENTLIST_POSTGRES_PASSWORD="$(echo \"id-management-module-db-password-salt\" | openssl rsautl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  IDMANAGER_LOCAL_PATIENTLIST_APIKEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"

  # Transform Seeds Configuration to pass it to the Mainzelliste Container
  PATIENTLIST_SEEDS_TRANSFORMED="$(declare -p PATIENTLIST_SEEDS | tr -d '\"' | sed 's/\[/\[\"/g' | sed 's/\]/\"\]/g')"

  # Ensure old ids are working !!!
  export IDMANAGEMENT_FRIENDLY_ID=$(legacyIdMapping "$SITE_ID")
fi
