#!/bin/bash

if [ -n "$ENABLE_OMICS" ];then
  OVERRIDE+=" -f ./$PROJECT/modules/itcc-omics-ingest.yaml"
  GENERATE_API_KEY="$(generate_simple_password 'omics')"
fi