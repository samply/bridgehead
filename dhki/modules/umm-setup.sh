#!/bin/bash

function ummSetup() {
  if [ "${ENABLE_UMM:-}" == "true" ]; then
    assertVarsNotEmpty TTP_URL TTP_ML_API_KEY PROJECT_ID_SYSTEM || \
      fail_and_report 1 "The UMM module requires TTP_URL, TTP_ML_API_KEY and PROJECT_ID_SYSTEM."

    log INFO "UMM TransFAIR setup detected -- will start TransFAIR, two dedicated Blaze stores and one Beam.Connect receiver."

    UMM_TRANSFAIR_BEAM_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"

    FHIR_REQUEST_URL="http://transfair-request-blaze:8080"
    FHIR_INPUT_URL="http://transfair-input-blaze:8080"

    OVERRIDE+=" -f ./dhki/modules/umm-compose.yml --profile transfair-request-blaze --profile transfair-input-blaze"
  fi
}
