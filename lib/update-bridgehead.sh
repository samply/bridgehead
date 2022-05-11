#!/bin/bash
source lib/functions.sh

log "INFO" "Checking for updates of services"

# Check git updates
for DIR in /etc/bridgehead $(pwd); do
  old_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  git -C $DIR fetch 2>&1
  git -C $DIR pull 2>&1
  new_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  git_updated="false"
  if [ "$old_git_hash" != "$new_git_hash" ]; then
    log "INFO" "Pulled new changes from origin"
    git_updated="true"
  fi
done

# Check docker updates
docker_updated="false"
for IMAGE in $(docker ps --filter "name=bridgehead" --format {{.Image}}); do
  log "INFO" "Checking for Updates of Image: $IMAGE"
  if docker pull $IMAGE | grep "Downloaded newer image"; then
    log "INFO" "$IMAGE updated."
    docker_updated="true"
  fi
done

# If anything is updated, restart service
if [ $git_updated = "true" ] || [ $docker_updated = "true" ]; then
  log "INFO" "Due to previous updates now restarting bridgehead"
  systemctl restart 'bridgehead@*'
fi
log "INFO" "checking updates finished"
exit 0