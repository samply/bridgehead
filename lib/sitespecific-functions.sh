#!/bin/bash -e
source lib/functions.sh
PROJECT="ccp"
log "INFO" "Adding custom encrypted credentials in /etc/bridgehead/$PROJECT.local.conf"
read -p "Please enter custom user: " user
read -s -p "Please enter password (will not be echoed): "$'\n' password
addBasicAuthUser $user $password "NNGM_AUTH" $PROJECT