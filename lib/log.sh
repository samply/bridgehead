#!/bin/bash

log() {
  SEVERITY="$1"
  shift
  echo -e "$(date +'%Y-%m-%d %T')" "$SEVERITY:" "$@"
}
