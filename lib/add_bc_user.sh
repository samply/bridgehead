#!/bin/bash -e
source lib/functions.sh

log "This script add's a user with password to the bridghead"

if [ $# -eq 0 ]; then
    log "No arguments provided, please provide the project name"
    exit 1
fi

if [ ! -f /etc/systemd/system/bridgehead@$1.service.d/override.conf ]; then
    log "Please create a Service first, with setup-bridgehead-units.sh"
    exit
fi

read -p 'Username: ' bc_user
read -sp 'Password: ' bc_password

echo


bc=`docker run --rm -it httpd:latest htpasswd -nb $bc_user $bc_password`

if grep -q -E "Environment=bc_auth_users=" /etc/systemd/system/bridgehead@$1.service.d/override.conf ; then
    x=`grep -E "Environment=bc_auth_users=" /etc/systemd/system/bridgehead@$1.service.d/override.conf`
    sed -i "/Environment=bc_auth_users=/c\\$x,$bc" /etc/systemd/system/bridgehead@$1.service.d/override.conf       
else 
    echo "Environment=bc_auth_users=${bc}" >> /etc/systemd/system/bridgehead@$1.service.d/override.conf
fi