#!/bin/bash -e

function nngmSetup() {
  if [ -n "$NNGM_CTS_APIKEY" ]; then
    log INFO "nNGM setup detected -- will start nNGM Connector."
    OVERRIDE+=" -f ./$PROJECT/modules/nngm-compose.yml"
  fi
}
