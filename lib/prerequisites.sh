#!/bin/bash

source lib/functions.sh

detectCompose
CONFIG_DIR="/etc/bridgehead/"
COMPONENT_DIR="/srv/docker/bridgehead/"

if ! id "bridgehead" &>/dev/null; then
  log ERROR "User bridgehead does not exist. Please run bridgehead install $PROJECT"
  exit 1
fi

checkOwner "${CONFIG_DIR}" bridgehead || exit 1
checkOwner "${COMPONENT_DIR}" bridgehead || exit 1

## Check if user is a su
log INFO "Checking if all prerequisites are met ..."
prerequisites="git docker curl"
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
if [ ! -d "${CONFIG_DIR}" ]; then
  fail_and_report 1 "Please set up the config folder at ${CONFIG_DIR}. Instruction are in the readme."
fi

# TODO: Check all required variables here in a generic loop

#check if project env is present
if [ -d "${CONFIG_DIR}${PROJECT}.conf" ]; then
   fail_and_report 1 "Project config not found. Please copy the template from ${PROJECT} and put it under ${CONFIG_DIR}${PROJECT}.conf."
fi

# TODO: Make sure you're in the right directory, or, even better, be independent from the working directory.

log INFO "Checking ssl cert for accessing bridgehead via https"

if [ ! -d "${CONFIG_DIR}traefik-tls" ]; then
  log WARN "TLS certs for accessing bridgehead via https missing, we'll now create a self-signed one. Please consider getting an officially signed one (e.g. via Let's Encrypt ...) and put into /etc/bridgehead/traefik-tls"
  mkdir -p /etc/bridgehead/traefik-tls
fi

if [ ! -e "${CONFIG_DIR}traefik-tls/fullchain.pem" ]; then
  openssl req -x509 -newkey rsa:4096 -nodes -keyout /etc/bridgehead/traefik-tls/privkey.pem -out /etc/bridgehead/traefik-tls/fullchain.pem -days 3650 -subj "/CN=$HOST"
fi

if [ -e "${CONFIG_DIR}"vault.conf ]; then
  if [ "$(stat -c "%a %U" /etc/bridgehead/vault.conf)" != "600 bridgehead" ]; then
    fail_and_report 1 "/etc/bridgehead/vault.conf has wrong owner/permissions. To correct this issue, run chmod 600 /etc/bridgehead/vault.conf && chown bridgehead /etc/bridgehead/vault.conf."
  fi
fi

log INFO "Checking network access ($BROKER_URL_FOR_PREREQ) ..."

source "${CONFIG_DIR}${PROJECT}".conf
source ${PROJECT}/vars

#if [ "${PROJECT}" != "minimal" ]; then
if false; then
  set +e
  SERVERTIME="$(https_proxy=$HTTPS_PROXY_FULL_URL curl -m 5 -s -I $BROKER_URL_FOR_PREREQ 2>&1 | grep -i -e '^Date: ' | sed -e 's/^Date: //i')"
  RET=$?
  set -e
  if [ $RET -ne 0 ]; then
	  log WARN "Unable to connect to Samply.Beam broker at $BROKER_URL_FOR_PREREQ. Please check your proxy settings.\nThe currently configured proxy was \"$HTTPS_PROXY_URL\". This error is normal when using proxy authentication."
  	log WARN "Unable to check clock skew due to previous error."
  else
	  log INFO "Checking clock skew ..."

    SERVERTIME_AS_TIMESTAMP=$(date --date="$SERVERTIME" +%s)
	  MYTIME=$(date +%s)
	  SKEW=$(($SERVERTIME_AS_TIMESTAMP - $MYTIME))
	  SKEW=$(echo $SKEW | awk -F- '{print $NF}')
	  SYNCTEXT="For example, consider entering a correct NTP server (e.g. your institution's Active Directory Domain Controller in /etc/systemd/timesyncd.conf (option NTP=) and restart systemd-timesyncd."
	  if [ $SKEW -ge 300 ]; then
		  report_error 5 "Your clock is not synchronized (${SKEW}s off). This will cause Samply.Beam's certificate will fail. Please setup time synchronization. $SYNCTEXT"
		  exit 1
	  elif [ $SKEW -ge 60 ]; then
		  log WARN "Your clock is more than a minute off (${SKEW}s). Consider syncing to a time server. $SYNCTEXT"
	  fi
  fi
fi
checkPrivKey() {
  if [ -e "${CONFIG_DIR}pki/${SITE_ID}.priv.pem" ]; then
    log INFO "Success - private key found."
  else
    log ERROR "Unable to find private key at ${CONFIG_DIR}pki/${SITE_ID}.priv.pem. To fix, please run\n  bridgehead enroll ${PROJECT}\nand follow the instructions."
    return 1
  fi
  return 0
}

if [[ "$@" =~ "noprivkey" ||  "${PROJECT}" != "minimal" ]]; then
  log INFO "Skipping check for private key for now."
else
  checkPrivKey || exit 1
fi

for dir in  "${CONFIG_DIR}" "${COMPONENT_DIR}"; do
  log INFO "Checking branch: $(cd $dir && echo "$dir $(git branch --show-current)")"
  hc_send log "Checking branch: $(cd $dir && echo "$dir $(git branch --show-current)")"
done

log INFO "Success - all prerequisites are met!"
hc_send log "Success - all prerequisites are met!"

exit 0
