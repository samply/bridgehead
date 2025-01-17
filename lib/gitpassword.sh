#!/bin/bash

[ "$1" = "get" ] || exit

source /var/cache/bridgehead/secrets/gitlab_token

# Any non-empty username works, only the token matters
cat << EOF
username=bk
password=$BRIDGEHEAD_CONFIG_REPO_TOKEN
EOF