#!/bin/bash

function dkfzSetup() {
  if [ "${ENABLE_DKFZ:-}" == "true" ]; then
    log INFO "DKFZ TransFAIR setup detected -- will start TransFAIR and Beam.Connect."
    DKFZ_TRANSFAIR_BEAM_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
    OVERRIDE+=" -f ./dhki/modules/dkfz-compose.yml"
  fi
}
