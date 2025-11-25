#!/bin/bash

if [ -n "$ENABLE_OMICS" ];then
  OVERRIDE+=" -f ./$PROJECT/modules/itcc-omics-ingest.yaml"
fi