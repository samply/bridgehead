#!/bin/bash

if [ -n "$ENABLE_ADT2FHIR_REST" ]; then
  log INFO "ADT2FHIR-REST setup detected -- will start adt2fhir-rest API."
  if [ ! -n "$IDMANAGER_LOCAL_PATIENTLIST_APIKEY" ]; then
    log ERROR "Missing ID-Management Module! Fix this by setting up ID Management:"
    exit 1;
  fi
  OVERRIDE+=" -f ./$PROJECT/modules/adt2fhir-rest-compose.yml"
  LOCAL_SALT="$(echo \"local-random-salt\" | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
fi
