#!/bin/bash -e

echo "This script add's a user with password to the bridghead"
read -p 'Username: ' bc_user
read -sp 'Password: ' bc_password

echo 

bc=$(docker run --rm -ti xmartlabs/htpasswd $bc_user $bc_password)

if [ -z $bc_auth_users ]; then
    printf "Please run: export bc_auth_users=\"%q\"" $bc
else
    echo "Please run: export bc_auth_users=\"${bc},$bc_auth_users\""
fi