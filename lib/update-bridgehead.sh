#!/bin/bash
source lib/functions.sh

CONFFILE=/etc/bridgehead/$1.conf

if [ ! -e $CONFFILE ]; then
  log ERROR "Configuration file $CONFFILE not found."
  exit 1
fi

source $CONFFILE

assertVarsNotEmpty SITE_ID || exit 1
export SITE_ID

checkOwner . bridgehead || exit 1
checkOwner /etc/bridgehead bridgehead || exit 1

CREDHELPER="/srv/docker/bridgehead/lib/gitpassword.sh"

# Check git updates
for DIR in /etc/bridgehead $(pwd); do
  log "INFO" "Checking for updates to git repo $DIR ..."
  if [ "$(git -C $DIR config --get credential.helper)" != "$CREDHELPER" ]; then
    log "INFO" "Configuring repo to use bridgehead git credential helper."
    git -C $DIR config credential.helper "$CREDHELPER"
  fi
  old_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  if [ -z "$HTTP_PROXY_URL" ]; then
    log "INFO" "Git is using no proxy!"
    git -C $DIR fetch 2>&1
    git -C $DIR pull 2>&1
  else
    log "INFO" "Git is using proxy ${HTTP_PROXY_URL} from ${CONFFILE}"
    git -c http.proxy=$HTTP_PROXY_URL -c http.proxy=$HTTP_PROXY_URL -C $DIR fetch 2>&1
    git -c http.proxy=$HTTP_PROXY_URL -c http.proxy=$HTTP_PROXY_URL -C $DIR pull 2>&1
  fi  new_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  git_updated="false"
  if [ "$old_git_hash" != "$new_git_hash" ]; then
    log "INFO" "Updated git repository in ${DIR} from commit $old_git_hash to $new_git_hash"
    # NOTE: Link generation doesn't work on repositories placed at an self-hosted instance of bitbucket.
    # See: https://community.atlassian.com/t5/Bitbucket-questions/BitBucket-4-14-diff-between-any-two-commits/qaq-p/632974
    git_repository_url="$(git -C $DIR remote get-url origin)"
    git_repository_url=${git_repository_url/.git/}
    if [ "$( echo $git_repository_url | grep "github.com")" ]; then
      # Ensure web link even if ssh is used
      git_repository_url="${git_repository_url/git@github.com/https:\/\/github.com\/}"
      log "INFO" "You can review all changes on the repository with $git_repository_url/compare/$old_git_hash...$new_git_hash"
    elif [ "$( echo $git_repository_url | grep "git.verbis.dkfz.de")" ]; then
      git_repository_url="${git_repository_url/ssh:\/\/git@git.verbis.dkfz.de/https:\/\/git.verbis.dkfz.de\/}"
      git_repository_url="https://$(echo $git_repository_url | awk -F '@' '{print $2}')"
      log "INFO" "You can review all changes on the repository with $git_repository_url/compare?from=$old_git_hash&to=$new_git_hash"
    fi
    git_updated="true"
  fi
done

# Check docker updates
log "INFO" "Checking for updates to running docker images ..."
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
  log "INFO" "Update detected, now restarting bridgehead"
  systemctl restart 'bridgehead@*'
else
  log "INFO" "Nothing updated, nothing to restart."
fi

exit 0

# TODO: Print last commit explicit
