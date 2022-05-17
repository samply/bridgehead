#!/bin/bash -e
source lib/functions.sh

log "INFO" "This script add's a user with password to the bridghead"

read -p 'Username: ' bc_user
read -sp 'Password: ' bc_password

log "INFO" "\nPlease export the line in the your environment. Please replace the dollar signs with with \\\$"
docker run --rm -it httpd:latest htpasswd -nb $bc_user $bc_password
