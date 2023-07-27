#!/bin/bash -e

source lib/functions.sh

PROJECT=$1

log "INFO" "Adding encrypted credentials in /etc/bridgehead/$PROJECT.local.conf"
read -p "Please choose the component (LDM_AUTH|NNGM_AUTH) you want to add a user to : " COMPONENT
read -p "Please enter a username: " USER
read -s -p "Please enter a password (will not be echoed): "$'\n' PASSWORD
add_basic_auth_user $USER $PASSWORD $COMPONENT $PROJECT