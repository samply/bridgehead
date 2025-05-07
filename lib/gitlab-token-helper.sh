#!/bin/bash

[ "$1" = "get" ] || exit

source "/tmp/bridgehead/secret-sync.boot-$(cat /proc/sys/kernel/random/boot_id)/gitlab-token"

# Any non-empty username works, only the token matters
cat << EOF
username=bk
password=$BRIDGEHEAD_CONFIG_REPO_TOKEN
EOF