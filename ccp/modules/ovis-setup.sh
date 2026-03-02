#!/bin/bash -e

if [ -n "$ENABLE_OVIS" ]; then
  if declare -F log >/dev/null 2>&1; then
    log INFO "OVIS setup detected -- will start OVIS services."
  fi
  mkdir -p "/var/cache/bridgehead/ccp/ovis/mongo/init"
  mkdir -p "/var/cache/bridgehead/ccp/ovis/shared_data"

  cat >"/var/cache/bridgehead/ccp/ovis/mongo/init/init.js" <<'EOF'
db = db.getSiblingDB("onc_test");
db.createCollection("user");
db.user.updateOne(
  { _id: "OVIS-Root" },
  {
    $setOnInsert: {
      _id: "OVIS-Root",
      createdAt: new Date(),
      createdBy: "system",
      role: "super-admin",
      status: "active",
      pseudonymization: false,
      darkMode: false,
      colorTheme: "CCCMunich",
      language: "de"
    }
  },
  { upsert: true }
);
EOF

  OVERRIDE+=" -f ./$PROJECT/modules/ovis-compose.yml"
fi
