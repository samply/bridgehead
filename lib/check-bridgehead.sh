#!/bin/bash
source lib/functions.sh

log INFO "Running Bridgehead checks..."

# Directory ownership
log INFO "Checking directory ownership..."
OWNERSHIP_OK=true
if ! checkOwner /srv/docker/bridgehead bridgehead &> /dev/null; then
  log ERROR "Wrong ownership for /srv/docker/bridgehead."
  log INFO "Hint: Run 'sudo chown -R bridgehead /srv/docker/bridgehead'."
  OWNERSHIP_OK=false
fi
if ! checkOwner /etc/bridgehead bridgehead &> /dev/null; then
  log ERROR "Wrong ownership for /etc/bridgehead."
  log INFO "Hint: Run 'sudo chown -R bridgehead /etc/bridgehead'."
  OWNERSHIP_OK=false
fi

if [ "$OWNERSHIP_OK" = true ]; then
  log INFO "Directory ownership is correct."
fi

# Git repository status
log INFO "Checking Git repository status..."
GIT_OK=true
if [ -d "/etc/bridgehead/.git" ]; then
  if [ -n "$(git -C "/etc/bridgehead" status --porcelain)" ]; then
    log ERROR "The config repo at /etc/bridgehead is modified.\n$(git -C /etc/bridgehead status -s)"
    log INFO "Hint: Review your changes with git diff if they are already upstreamed use git stash and git pull to update the repo"
    GIT_OK=false
  fi
fi
if [ -n "$(git -C "$(pwd)" status --porcelain)" ]; then
  log ERROR "$(pwd) is modified. \n$(git -C "$(pwd)" status -s)"
  log INFO "Hint: If these are site specific changes to docker compose files consider moving them to $PROJECT/docker-compose.override.yml which is ignored by git."
  log INFO "      If they are already upstreamed use git stash and git pull to update the repo"
  GIT_OK=false
fi

if [ "$GIT_OK" = true ]; then
  log INFO "Git repositories are clean."
fi

# Git remote connection
log INFO "Checking Git remote connection..."
GIT_REMOTE_OK=true
if [ -d "/etc/bridgehead/.git" ]; then
  if ! git -C "/etc/bridgehead" fetch --dry-run >/dev/null 2>&1; then
    log ERROR "Cannot connect to the Git remote for /etc/bridgehead."
    log INFO "Hint: Check your network connection and Git remote configuration for /etc/bridgehead."
    GIT_REMOTE_OK=false
  fi
fi
if [ -d "$(pwd)/.git" ]; then
  if ! git -C "$(pwd)" fetch --dry-run >/dev/null 2>&1; then
    log ERROR "Cannot connect to the Git remote for $(pwd)."
    log INFO "Hint: Check your network connection and Git remote configuration for $(pwd)."
    GIT_REMOTE_OK=false
  fi
fi

if [ "$GIT_REMOTE_OK" = true ]; then
  log INFO "Git remote connection successful."
fi

if [ "$OWNERSHIP_OK" = true ] && [ "$GIT_OK" = true ] && [ "$GIT_REMOTE_OK" = true ]; then
  log INFO "All checks passed."
  exit 0
else
  log ERROR "Some checks failed. Please review the hints and fix the issues."
  log ERROR "Without fixing these issues bridgehead updates may not work correctly."
  exit 1
fi
