#!/bin/bash

log INFO "######################################### Metadata feedback script was found by Bridgehead"

if [ "$ENABLE_FEEDBACK_AGENT" == true ]; then
  log INFO "######################################### Metadata feedback setup detected -- will start Feedback service."
  OVERRIDE+=" -f ./$PROJECT/modules/feedback-agent-compose.yml"
  FEEDBACK_AGENT_BEAM_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
  FEEDBACK_AGENT_DB_PASSWORD="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
fi

