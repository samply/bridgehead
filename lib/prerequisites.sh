#!/bin/bash

source lib/functions.sh

if ! id "bridgehead" &>/dev/null; then
  log ERROR "User bridgehead does not exist. Please consult readme for installation."
  exit 1
fi

checkOwner . bridgehead || exit 1
checkOwner /etc/bridgehead bridgehead || exit 1

## Check if user is a su
log INFO "Checking if all prerequisites are met ..."
prerequisites="git docker docker-compose"
for prerequisite in $prerequisites; do
  $prerequisite --version 2>&1
  is_available=$?
  if [ $is_available -gt 0 ]; then
    fail_and_report 79 "Prerequisite not fulfilled - $prerequisite is not available!"
  fi
  # TODO: Check for specific version
done

log INFO "Checking if sudo is installed ..."
if [ ! -d /etc/sudoers.d ]; then
  fail_and_report 1 "/etc/sudoers.d does not exist. Please install sudo package."
fi

log INFO "Checking configuration ..."

## Download submodule
if [ ! -d "/etc/bridgehead/" ]; then
  fail_and_report 1 "Please set up the config folder at /etc/bridgehead. Instruction are in the readme."
fi

# TODO: Check all required variables here in a generic loop

#check if project env is present
if [ -d "/etc/bridgehead/${PROJECT}.conf" ]; then
   fail_and_report 1 "Project config not found. Please copy the template from ${PROJECT} and put it under /etc/bridgehead-config/${PROJECT}.conf."
fi

# TODO: Make sure you're in the right directory, or, even better, be independent from the working directory.

log INFO "Checking ssl cert for accessing bridgehead via https"

if [ ! -d "/etc/bridgehead/traefik-tls" ]; then
  log WARN "TLS certs for accessing bridgehead via https missing, we'll now create a self-signed one. Please consider getting an officially signed one (e.g. via Let's Encrypt ...) and put into /etc/bridgehead/traefik-tls"
  mkdir -p /etc/bridgehead/traefik-tls
fi

if [ ! -e "/etc/bridgehead/traefik-tls/fullchain.pem" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes -keyout /etc/bridgehead/traefik-tls/privkey.pem -out /etc/bridgehead/traefik-tls/fullchain.pem -days 3650 -subj "/CN=$HOST"
fi

if [ -e /etc/bridgehead/vault.conf ]; then
  if [ "$(stat -c "%a %U" /etc/bridgehead/vault.conf)" != "600 bridgehead" ]; then
    fail_and_report 1 "/etc/bridgehead/vault.conf has wrong owner/permissions. To correct this issue, run chmod 600 /etc/bridgehead/vault.conf && chown bridgehead /etc/bridgehead/vault.conf."
  fi
fi

log INFO "Checking your beam proxy private key"

if [ -e /etc/bridgehead/pki/${SITE_ID}.priv.pem ]; then
  log INFO "Success - private key found."
else
  log ERROR "Unable to find private key at /etc/bridgehead/pki/${SITE_ID}.priv.pem. To fix, please run bridgehead enroll ${PROJECT} and follow the instructions".
  exit 1
fi

log INFO "Success - all prerequisites are met!"
hc_send log "Success - all prerequisites are met!"

exit 0
