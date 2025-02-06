#!/bin/bash

if [ "$ENABLE_FEEDBACK_AGENT" == true ]; then
  OVERRIDE+=" -f ./$PROJECT/modules/feedback-agent-compose.yml"
  FEEDBACK_AGENT_BEAM_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
  FEEDBACK_AGENT_DB_PASSWORD="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
fi

