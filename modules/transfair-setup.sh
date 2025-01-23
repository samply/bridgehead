#!/bin/bash -e

function transfairSetup() {
    if [[ -n "$INSTITUTE_TTP_URL" || -n "$EXCHANGE_ID_SYSTEM" ]]; then
        echo "Starting transfair."
    else
        return
    fi
	OVERRIDE+=" -f ./modules/transfair-compose.yml"
	if [ -n "$FHIR_INPUT_URL" ]; then
		log INFO "TransFAIR input fhir store set to external $FHIR_INPUT_URL"
	else
		log INFO "TransFAIR input fhir store not set writing to internal blaze"
		FHIR_INPUT_URL="http://bridgehead-transfair-input-blaze:8080"
		OVERRIDE+=" --profile transfair-input-blaze"
	fi
	if [ -n "$FHIR_REQUEST_URL" ]; then
		log INFO "TransFAIR request fhir store set to external $FHIR_REQUEST_URL"
	else
		log INFO "TransFAIR request fhir store not set writing to internal blaze"
		FHIR_REQUEST_URL="http://bridgehead-transfair-requests-blaze:8080"
		OVERRIDE+=" --profile transfair-request-blaze"
	fi
}
