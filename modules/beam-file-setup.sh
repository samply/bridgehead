#!/bin/bash -e

function beamFileSetup() {
    if [ -n "$ENABLE_BEAM_FILE_SENDER" ]; then
       echo "Starting beam file in sender mode"
       OVERRIDE+=" -f ./modules/beam-file-compose.yml --profile beam-file-sender"
       BEAM_FILE_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
       # NOTE: We could make this persistent across restarts
       BEAM_FILE_API_KEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
       log INFO "Beam File in Sender Mode available uses ApiKey ${BEAM_FILE_API_KEY}"
    elif [ -n "$ENABLE_BEAM_FILE_RECEIVER" ]; then
       echo "Starting beam file in receiver mode"
       OVERRIDE+=" -f ./modules/beam-file-compose.yml --profile beam-file-receiver"
       BEAM_FILE_SECRET="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
       BEAM_FILE_API_KEY="$(cat /proc/sys/kernel/random/uuid | sed 's/[-]//g' | head -c 20)"
       log INFO "Beam File in Receiver Mode available uses ApiKey ${BEAM_FILE_API_KEY}"
    fi
}
