#!/bin/bash

function lensSetup() {
  if [ -n "$ENABLE_LENS" ];then
    OVERRIDE+=" -f ./$PROJECT/modules/lens-compose.yml"
  fi
}