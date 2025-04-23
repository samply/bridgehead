#!/bin/bash -e

function transfairSetup() {
    if [[ -n "$TTP_URL" || -n "$EXCHANGE_ID_SYSTEM" ]]; then
        echo "Starting transfair."
	    OVERRIDE+=" -f ./modules/transfair-compose.yml"
	    if [ -n "$FHIR_INPUT_URL" ]; then
		    log INFO "TransFAIR input fhir store set to external $FHIR_INPUT_URL"
	    else
		    log INFO "TransFAIR input fhir store not set writing to internal blaze"
		    FHIR_INPUT_URL="http://transfair-input-blaze:8080"
		    OVERRIDE+=" --profile transfair-input-blaze"
	    fi
	    if [ -n "$FHIR_REQUEST_URL" ]; then
		    log INFO "TransFAIR request fhir store set to external $FHIR_REQUEST_URL"
	    else
		    log INFO "TransFAIR request fhir store not set writing to internal blaze"
		    FHIR_REQUEST_URL="http://transfair-requests-blaze:8080"
		    OVERRIDE+=" --profile transfair-request-blaze"
	    fi
	    if [ -n "$TTP_GW_SOURCE" ]; then
		    log INFO "TransFAIR configured with greifswald as ttp"
		    TTP_TYPE="greifswald"
	    elif [ -n "$TTP_ML_API_KEY" ]; then
		    log INFO "TransFAIR configured with mainzelliste as ttp"
		    TTP_TYPE="mainzelliste"
        else
		    log INFO "TransFAIR configured without ttp"
	    fi
        TRANSFAIR_NO_PROXIES="transfair-input-blaze,blaze,transfair-requests-blaze"
        if [ -n "${TRANSFAIR_NO_PROXY}" ]; then
            TRANSFAIR_NO_PROXIES+=",${TRANSFAIR_NO_PROXY}"
        fi
    fi
}
