#!/bin/bash

function blazeSecondarySetup() {
  if [ -n "$ENABLE_SECONDARY_BLAZE" ]; then
    log INFO "Secondary Blaze setup detected -- will start second blaze."
    OVERRIDE+=" -f ./common/blaze-secondary-compose.yml"
    #make oBDS2FHIR ignore ID-Management and replace target Blaze
    PATIENTLIST_URL=" "
    STORE_PATH="http://blaze-secondary:8080/fhir"
  fi
}
