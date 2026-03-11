#!/bin/bash

if [ -n "$DATA_QUALITY_SERVER_URL" ] && [ -n "$DATA_QUALITY_SERVER_NAME" ]; then
    log INFO "Data Quality Agent setup detected -- will start data-quality-agent service."
    OVERRIDE+=" -f ./$PROJECT/modules/data-quality-agent-compose.yml"
fi

