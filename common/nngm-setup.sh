#!/bin/bash -e

if [ -n "$NNGM_CTS_APIKEY" ]; then
  log INFO "nNGM setup detected -- will start nNGM Connector."
  OVERRIDE+=" -f ./common/nngm-compose.yml"
fi
