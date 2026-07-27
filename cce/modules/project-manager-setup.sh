#!/bin/bash -e

if [ "$ENABLE_PROJECT_MANAGER" == true ]; then
  log INFO "Project Manager setup detected -- will start Project Manager services."
  OVERRIDE+=" -f ./$PROJECT/modules/project-manager-compose.yml"

  POSTGRES_VERSION="${POSTGRES_VERSION:-$POSTGRES_TAG}"
  MAILPIT_VERSION="${MAILPIT_VERSION:-latest}"
  DBEAVER_VERSION="${DBEAVER_VERSION:-latest}"
  DBEAVER_USER="${DBEAVER_USER:-admin}"

  BEAM_SECRET_PROJECT_MANAGER="$(echo \"This is a salt string to generate one consistent beam secret for the project manager. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 64)"
  PROJECT_MANAGER_DB_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the project manager database. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  PROJECT_MANAGER_DB_ENCRYPTION_PRIVATE_KEY_IN_BASE64="$(echo \"This is a salt string to generate one encriptyion privae key for the project manager. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 64)"
  DBEAVER_PASSWORD="$(echo \"This is a salt string to generate one consistent password for the project manager database GUI. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  SQL_GUI_AUTH="$(echo \"This is a salt string to generate one consistent basic authentication password for the project manager database GUI. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"
  TEST_SMTP_AUTH="$(echo \"This is a salt string to generate one consistent basic authentication password for the project manager test SMTP server. It is not required to be secret.\" | sha1sum | openssl pkeyutl -sign -inkey /etc/bridgehead/pki/${SITE_ID}.priv.pem | base64 | head -c 30)"

  add_public_oidc_redirect_url "/requester/*"
fi
