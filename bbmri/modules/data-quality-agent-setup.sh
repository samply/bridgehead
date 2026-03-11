#!/bin/bash

if [ "$ENABLE_DATA_QUALITY_AGENT" == "true" ]; then
    log INFO "Data Quality Agent setup detected -- will start data-quality-agent service."
    OVERRIDE+=" -f ./$PROJECT/modules/data-quality-agent-compose.yml"
fi

