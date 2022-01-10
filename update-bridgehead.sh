#!/bin/bash
service="bridgehead"

source lib/functions.sh

log "INFO" "Checking for updates of $service"
# check prerequisites
##TODO: Move to lib/prereq.sh
prerequisites="git docker docker-compose"
for prerequisite in $prerequisites; do
  $prerequisite --version 2>&1
  is_available=$?
  if [ $is_available -gt 0 ]; then
    log "ERROR" "Prerequisite not fulfilled - $prerequisite is not available!"
    exit 79
  fi
done
# check if updates are available
old_git_hash="$(git rev-parse --verify HEAD)"
git fetch 2>&1
git pull 2>&1
new_git_hash="$(git rev-parse --verify HEAD)"
git_updated="false"
if [ "$old_git_hash" != "$new_git_hash" ]; then
  log "INFO" "Pulled new changes from origin"
  git_updated="true"
fi
docker_updated="false"
for image in $(docker ps --filter "name=$service" --format {{.Image}}); do
  log "INFO" "Checking for Updates of Image: $image"
  if docker pull $image | grep "Downloaded newer image"; then
    log "INFO" "$image updated."
    docker_updated="true"
  fi
done
if [ $git_updated = "true" ] || [ $docker_updated = "true" ]; then
  log "INFO" "Due to previous updates now restarting $service@$1"
  systemctl restart "$service@$1.service"
fi
log "INFO" "checking updates finished"
exit 0
