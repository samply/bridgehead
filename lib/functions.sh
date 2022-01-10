#!/bin/bash -e

exitIfNotRoot() {
  if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
  fi
}

log() {
  echo "$(date +'%Y-%m-%d %T')" "$1:" "$2"
}
