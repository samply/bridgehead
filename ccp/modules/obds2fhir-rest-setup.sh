#!/bin/bash

function obds2fhirRestSetup() {
  if [ -n "$ENABLE_OBDS2FHIR_REST" ]; then
    log INFO "oBDS2FHIR-REST setup detected -- will start obds2fhir-rest module."
    if [ ! -n "$IDMANAGER_LOCAL_PATIENTLIST_APIKEY" ]; then
      log ERROR "Missing ID-Management Module! Fix this by setting up ID Management:"
      PATIENTLIST_URL=" "
    fi
    OVERRIDE+=" -f ./$PROJECT/modules/obds2fhir-rest-compose.yml"
    LOCAL_SALT="$(echo \"local-random-salt\" | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  fi
}
