#!/bin/bash

if [ -n "$ENABLE_LENS" ];then
  OVERRIDE+=" -f ./common/lens-compose.yml"
fi