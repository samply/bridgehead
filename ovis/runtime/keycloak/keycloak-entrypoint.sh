#!/usr/bin/env bash
set -euo pipefail

IMPORT_DIR="${KEYCLOAK_IMPORT_DIR:-/opt/keycloak/data/import}"
export BASE_REALM="${BASE_REALM:-/realm-base/ovis-realm.json}"
export OUTPUT_REALM="${OUTPUT_REALM:-$IMPORT_DIR/ovis-realm.json}"
KEYCLOAK_HTTP_RELATIVE_PATH="${KEYCLOAK_HTTP_RELATIVE_PATH:-/keycloak}"

echo "=== Starting OVIS Keycloak bootstrap ==="
echo "Keycloak certificate directory:"
ls -lh /etc/keycloak/certs || true

mkdir -p "$IMPORT_DIR"

echo "Building dynamic realm configuration at $OUTPUT_REALM..."
tr -d '\r' < /build-realm.sh \
  | sed 's|OUTPUT_REALM="/import/ovis-realm.json"|OUTPUT_REALM="${OUTPUT_REALM:-/opt/keycloak/data/import/ovis-realm.json}"|' \
  | sh

if [ -n "${KEYCLOAK_ADMIN_CLIENT_SECRET:-}" ]; then
  echo "Updating admin client secret for ${KEYCLOAK_ADMIN_CLIENT_ID:-admin-cli}..."
  tmp_realm="${OUTPUT_REALM}.tmp"
  sed "/\"clientId\"[[:space:]]*:[[:space:]]*\"${KEYCLOAK_ADMIN_CLIENT_ID:-admin-cli}\"/,/\"secret\"[[:space:]]*:/ s|\"secret\"[[:space:]]*:[[:space:]]*\"[^\"]*\"|\"secret\": \"${KEYCLOAK_ADMIN_CLIENT_SECRET}\"|" "$OUTPUT_REALM" > "$tmp_realm"
  mv "$tmp_realm" "$OUTPUT_REALM"
fi

DB_HOST="${DB_ADDR:-postgres}"
DB_PORT="${DB_PORT:-5432}"
DB_WAIT_SECONDS="${KEYCLOAK_DB_WAIT_SECONDS:-120}"
DB_POLL_INTERVAL="${KEYCLOAK_DB_WAIT_POLL_INTERVAL:-2}"

echo "Waiting for PostgreSQL at ${DB_HOST}:${DB_PORT} (timeout: ${DB_WAIT_SECONDS}s)..."
elapsed=0
until timeout 1 bash -c "</dev/tcp/${DB_HOST}/${DB_PORT}" 2>/dev/null; do
  elapsed=$((elapsed + DB_POLL_INTERVAL))
  if [ "$elapsed" -ge "$DB_WAIT_SECONDS" ]; then
    echo "ERROR: PostgreSQL did not become reachable within ${DB_WAIT_SECONDS}s"
    exit 1
  fi
  echo "PostgreSQL not reachable yet (${elapsed}s elapsed); retrying in ${DB_POLL_INTERVAL}s..."
  sleep "$DB_POLL_INTERVAL"
done

echo "Importing Keycloak realm from $IMPORT_DIR..."
/opt/keycloak/bin/kc.sh import --dir "$IMPORT_DIR" --override true

if [ "${OVIS_KEYCLOAK_USE_IMAGE_CMD:-false}" = "true" ] && [ "$#" -gt 0 ]; then
  keycloak_args=("$@")
else
  keycloak_hostname="${KEYCLOAK_HOSTNAME:-${APP_DOMAIN:-localhost}}"
  keycloak_args=(
    start
    --http-enabled=true
    --proxy-headers=xforwarded
    --hostname="$keycloak_hostname"
    --hostname-strict=true
    --http-relative-path="$KEYCLOAK_HTTP_RELATIVE_PATH"
  )
fi

if [ "${PUBLIC_LDAP_ENABLED:-}" = "true" ] && [ -n "${LDAP_CERTIFICATE_NAME:-}" ] && [ -f "/etc/keycloak/certs/${LDAP_CERTIFICATE_NAME}" ]; then
  echo "LDAP enabled: loading certificate ${LDAP_CERTIFICATE_NAME}"
  keycloak_args+=("--truststore-paths=/etc/keycloak/certs/${LDAP_CERTIFICATE_NAME}")
else
  echo "LDAP disabled or certificate not found: skipping certificate loading"
fi

echo "Starting Keycloak..."
exec /opt/keycloak/bin/kc.sh "${keycloak_args[@]}"
