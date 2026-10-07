#!/bin/bash
source lib/functions.sh

if [ -t 1 ]; then
  GREEN=$(printf '\033[32m')
  YELLOW=$(printf '\033[33m')
  RED=$(printf '\033[31m')
  RESET=$(printf '\033[0m')
else
  GREEN=""
  YELLOW=""
  RED=""
  RESET=""
fi

WORST=0

report() {
  local status=$1 message=$2 color level label
  shift 2
  case "$status" in
    OK) color=$GREEN; level=0; label=" OK " ;;
    WARN) color=$YELLOW; level=1; label="WARN" ;;
    *) color=$RED; level=2; label="CRIT" ;;
  esac
  printf '[%s%s%s] %s\n' "$color" "$label" "$RESET" "$message"
  local hint
  for hint in "$@"; do
    printf '%s\n' "$hint" | sed 's/^/       /'
  done
  if [ $level -gt $WORST ]; then
    WORST=$level
  fi
}

GIT_PROXY_ARGS=()
if [ -n "$HTTPS_PROXY_FULL_URL" ]; then
  GIT_PROXY_ARGS=(-c http.proxy=$HTTPS_PROXY_FULL_URL -c https.proxy=$HTTPS_PROXY_FULL_URL)
fi

echo "Running Bridgehead checks for project $PROJECT ..."

if [ -n "$BROKER_URL_FOR_PREREQ" ]; then
  if https_proxy=$HTTPS_PROXY_FULL_URL curl -m 10 -sS -o /dev/null "$BROKER_URL_FOR_PREREQ" 2>/dev/null; then
    report OK "Network connection to $BROKER_URL_FOR_PREREQ"
  else
    report CRIT "Cannot connect to $BROKER_URL_FOR_PREREQ with the configured proxy \"$HTTPS_PROXY_URL\"" \
      "Hint: If your server needs a proxy, HTTPS_PROXY_URL (and, if required, HTTPS_PROXY_USERNAME and HTTPS_PROXY_PASSWORD) must be set in /etc/bridgehead/$PROJECT.conf. Please ask ${SUPPORT_EMAIL:-the support team of your project} to add it to your site configuration."
  fi
fi

for DIR in /srv/docker/bridgehead /etc/bridgehead; do
  if checkOwner $DIR bridgehead &> /dev/null; then
    report OK "Ownership of $DIR"
  else
    report CRIT "Wrong ownership for $DIR" "Hint: Run 'sudo chown -R bridgehead $DIR'."
  fi
done

if [ -d "/etc/bridgehead/.git" ]; then
  if [ -z "$(git -C "/etc/bridgehead" status --porcelain)" ]; then
    report OK "The config repo at /etc/bridgehead is clean"
  else
    report WARN "The config repo at /etc/bridgehead is modified:" \
      "$(git -C /etc/bridgehead status -s)" \
      "Hint: Review your changes with git diff if they are already upstreamed use git stash and git pull to update the repo"
  fi
fi
if [ -z "$(git -C "$(pwd)" status --porcelain)" ]; then
  report OK "$(pwd) is clean"
else
  report WARN "$(pwd) is modified:" \
    "$(git -C "$(pwd)" status -s)" \
    "Hint: If these are site specific changes to docker compose files consider moving them to $PROJECT/docker-compose.override.yml which is ignored by git." \
    "      If they are already upstreamed use git stash and git pull to update the repo"
fi

secret_sync_gitlab_token &> /dev/null

for DIR in /etc/bridgehead "$(pwd)"; do
  if [ -d "$DIR/.git" ]; then
    if git "${GIT_PROXY_ARGS[@]}" -C "$DIR" fetch --dry-run >/dev/null 2>&1; then
      report OK "Git remote connection for $DIR"
    else
      report CRIT "Cannot connect to the Git remote for $DIR" "Hint: Check your network connection and Git remote configuration for $DIR."
    fi
  fi
done

case $WORST in
  0) echo "All checks passed." ;;
  1) echo "Some checks reported warnings. Please review the hints." ;;
  *) echo "Some checks failed. Please review the hints and fix the issues. Without fixing these issues bridgehead updates may not work correctly." ;;
esac
exit $WORST
