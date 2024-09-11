#!/bin/bash

if [ -n "${ENABLE_ONKOFDZ}" ]; then
  BROKER_ID=test-no-real-data.broker.samply.de
  BROKER_URL=https://${BROKER_ID}
  PROXY_ID=${SITE_ID}.${BROKER_ID}
  BEAMSEL_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
  SUPPORT_EMAIL=support-ccp@dkfz-heidelberg.de
  PRIVATEKEYFILENAME=/etc/bridgehead/pki/${SITE_ID}.priv.pem

  BROKER_URL_FOR_PREREQ=$BROKER_URL

  log INFO "Loading OnkoFDZ module"
  OVERRIDE+=" -f ./$PROJECT/modules/onkofdz-compose.yml"
fi
