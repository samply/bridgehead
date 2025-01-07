#!/bin/bash -eu

#echo "Called: $@" >> /tmp/credhelper

SECRETS_FILE=/var/cache/bridgehead/secrets/gitetcbridgehead

case "$1" in
  erase)
    rm -f $SECRETS_FILE
    CLEAN_REPO="$(git -C /etc/bridgehead remote get-url origin | sed -E 's|https://[^@]+@|https://|')"
    git -C /etc/bridgehead remote set-url origin $CLEAN_REPO
    exit 0
    ;;
  get)
    # continue below
    ;;
  store)
    # We could store the credentials in /var/cache/bridgehead, but we already did -- so nothing to do
    exit 0
    ;;
  *)
    fail_and_report 1 "gitpassword.sh called incorrectly"
    ;;
esac

PARAMS="$(cat)"
GITHOST=$(echo "$PARAMS" | grep "^host=" | sed 's/host=\(.*\)/\1/g')

if [ ! -f ${SECRETS_FILE} ]; then
   TMPFILE=$(mktemp)
   docker run --rm \
        -v $TMPFILE:/usr/local/cache \
        -v $PRIVATEKEYFILENAME:/run/secrets/privkey.pem:ro \
        -v /srv/docker/bridgehead/$PROJECT/root.crt.pem:/run/secrets/root.crt.pem:ro \
        -v /etc/bridgehead/trusted-ca-certs:/conf/trusted-ca-certs:ro \
        -e TLS_CA_CERTIFICATES_DIR=/conf/trusted-ca-certs \
        -e NO_PROXY=localhost,127.0.0.1 \
        -e ALL_PROXY=$HTTPS_PROXY_FULL_URL \
        -e PROXY_ID=$PROXY_ID \
        -e BROKER_URL=$BROKER_URL \
        -e OIDC_PROVIDER=secret-sync-central.oidc-client-enrollment.$BROKER_ID \
        -e SECRET_DEFINITIONS=GitLabProjectAccessToken:GIT_CONFIG_REPO_TOKEN:bridgehead-configuration \
        docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest
    mv $TMPFILE $SECRETS_FILE
fi

source "${SECRETS_FILE}"

if [ -z ${GIT_CONFIG_REPO_TOKEN} ]; then
	rm "${SECRETS_FILE}"
	fail_and_report 1 "gitpassword.sh failed: Git password file present but without token."
fi

REPO="$(git -C /etc/bridgehead remote get-url origin | sed -E 's|https://[^@]+@|https://|' | sed -E 's|https://||')"
if ! git -c http.proxy=$HTTPS_PROXY_FULL_URL -c https.proxy=$HTTPS_PROXY_FULL_URL ls-remote https://bk-$SITE_ID:${GIT_CONFIG_REPO_TOKEN}@${REPO} 1>/dev/null 2>/dev/null 3>/dev/null; then
	rm "${SECRETS_FILE}"
	fail_and_report 1 "gitpassword.sh failed: Git password present but invalid."
fi

cat <<EOF
protocol=https
host=$GITHOST
username=bk-${SITE_ID}
password=${GIT_CONFIG_REPO_TOKEN}
EOF

exit 0
