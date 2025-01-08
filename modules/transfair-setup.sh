#!/bin/bash -e

function transfairSetup() {
	assertVarsNotEmpty INSTITUTE_TTP_URL INSTITUTE_TTP_API_KEY PROJECT_ID_SYSTEM FHIR_REQUEST_URL FHIR_INPUT_URL
	OVERRIDE+=" -f ./modules/transfair-compose.yml"
	if [ -n "$FHIR_OUTPUT_URL" ]; then
		log INFO "TransFAIR output fhir store set to external $FHIR_OUTPUT_URL"
	else
		log INFO "TransFAIR output fhir store not set writing to internal blaze"
		FHIR_OUTPUT_URL="http://transfair-blaze:8080"
		OVERRIDE+=" -f ./modules/transfair-compose.yml"
	fi
}
