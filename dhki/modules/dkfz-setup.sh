#!/bin/bash

function dkfzSetup() {
  if [ "${ENABLE_DKFZ:-}" == "true" ]; then
    assertVarsNotEmpty DKFZ_TTP_URL DKFZ_TTP_ML_API_KEY || \
      fail_and_report 1 "The DKFZ module requires DKFZ_TTP_URL and DKFZ_TTP_ML_API_KEY."

    log INFO "DKFZ TransFAIR setup detected -- will start TransFAIR and Beam.Connect."
    DKFZ_TRANSFAIR_BEAM_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
    OVERRIDE+=" -f ./dhki/modules/dkfz-compose.yml"
  fi
}
