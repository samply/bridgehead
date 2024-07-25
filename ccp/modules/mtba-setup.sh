#!/bin/bash -e

function mtbaSetup() {
  if [ -n "$ENABLE_MTBA" ];then
    log INFO "MTBA setup detected -- will start MTBA Service and CBioPortal."
    if [ ! -n "$IDMANAGER_UPLOAD_APIKEY" ]; then
      log ERROR "Missing ID-Management Module! Fix this by setting up ID Management:"
    fi
    OVERRIDE+=" -f ./$PROJECT/modules/mtba-compose.yml"
    add_private_oidc_redirect_url "/mtba/*"
  fi
}
