#!/bin/bash

function mtbaSetup() {
  if [ -n "$ENABLE_MTBA" ];then
    log INFO "MTBA setup detected -- will start MTBA Service and CBioPortal."
    if [ ! -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
      log ERROR "Missing ID-Management Module! Fix this by setting up ID Management:"
      exit 1;
    fi
    OVERRIDE+=" -f ./$PROJECT/modules/mtba-compose.yml"
  fi
}
