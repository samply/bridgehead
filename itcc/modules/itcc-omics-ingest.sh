#!/bin/bash

if [ -n "$ENABLE_OMICS" ];then
  OVERRIDE+=" -f ./$PROJECT/modules/itcc-omics-ingest.yaml"
  GENERATE_API_KEY="$(generate_simple_password 'omics')"
  PATIENTLIST_POSTGRES_PASSWORD=="$(generate_simple_password 'mainzelliste')"
  KEYSET=/etc/bridgehead/mainzelliste/keyset_siv.json
  if [ ! -f "$KEYSET" ]; then
    mkdir -p "$(dirname "$KEYSET")"
    KEY_ID=$(($(openssl rand -hex 4 | sed 's/^/0x/') & 0x7FFFFFFF))
    VALUE=$({ printf '\x12\x40'; openssl rand 64; } | base64 | tr -d '\n')
    jq -n --argjson id "$KEY_ID" --arg value "$VALUE" '{
      primaryKeyId: $id,
      key: [{
        keyData: {
          typeUrl: "type.googleapis.com/google.crypto.tink.AesSivKey",
          value: $value,
          keyMaterialType: "SYMMETRIC"
        },
        status: "ENABLED",
        keyId: $id,
        outputPrefixType: "TINK"
      }]
    }' > "$KEYSET"
    chmod 600 "$KEYSET"
  fi
fi