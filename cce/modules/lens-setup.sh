#!/bin/bash

if [ -n "$ENABLE_LENS" ];then
  LENS_AUTH_COOKIE_SECRET="$(echo "This is a salt string to generate one consistent cookie secret for the Lens oauth2 proxy." | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | tr -d '\n' | head -c 32)"
  OVERRIDE+=" -f ./$PROJECT/modules/lens-compose.yml"

  LENS_OIDC_PRIVATE_URL="https://sso.verbis.dkfz.de/application/o/cce-project-manager-api/"
  LENS_OIDC_PRIVATE_CLIENT_ID="cce-project-manager-api"
  LENS_OIDC_PRIVATE_SECRET="$(echo \"This is a salt string to generate the private secret for the project manager oidc public client. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"

fi
