#!/bin/bash
source lib/functions.sh

AUTO_HOUSEKEEPING=${AUTO_HOUSEKEEPING:-true}

if [ "$AUTO_HOUSEKEEPING" == "true" ]; then
	A="Performing automatic maintenance: "
	if bk_is_running; then
		A="$A Cleaning docker images."
		docker system prune -a -f
	else
		A="$A Not cleaning docker images since BK is not running."
	fi
	hc_send log "$A"
	log INFO "$A"
else
	log WARN "Automatic housekeeping disabled (variable AUTO_HOUSEKEEPING != \"true\")"
fi

hc_send log "Checking for bridgehead updates ..."

CONFFILE=/etc/bridgehead/$1.conf

if [ ! -e $CONFFILE ]; then
  fail_and_report 1 "Configuration file $CONFFILE not found."
fi

source $CONFFILE

assertVarsNotEmpty SITE_ID || fail_and_report 1 "Update failed: SITE_ID empty"
export SITE_ID

checkOwner . bridgehead || fail_and_report 1 "Update failed: Wrong permissions in $(pwd)"
checkOwner /etc/bridgehead bridgehead || fail_and_report 1 "Update failed: Wrong permissions in /etc/bridgehead"

CREDHELPER="/srv/docker/bridgehead/lib/gitpassword.sh"

CHANGES=""

# Check git updates
git_updated="false"
for DIR in /etc/bridgehead $(pwd); do
  log "INFO" "Checking for updates to git repo $DIR ..."
  OUT="$(git -C $DIR status --porcelain)"
  if [ -n "$OUT" ]; then
    report_error log "The working directory $DIR is modified. Changed files: $OUT"
  fi
  if [ "$(git -C $DIR config --get credential.helper)" != "$CREDHELPER" ]; then
    log "INFO" "Configuring repo to use bridgehead git credential helper."
    git -C $DIR config credential.helper "$CREDHELPER"
  fi
  old_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  if [ -z "$HTTP_PROXY_URL" ]; then
    log "INFO" "Git is using no proxy!"
    OUT=$(retry 5 git -C $DIR fetch 2>&1 && retry 5 git -C $DIR pull 2>&1)
  else
    log "INFO" "Git is using proxy ${HTTP_PROXY_URL} from ${CONFFILE}"
    OUT=$(retry 5 git -c http.proxy=$HTTP_PROXY_URL -c https.proxy=$HTTPS_PROXY_URL -C $DIR fetch 2>&1 && retry 5 git -c http.proxy=$HTTP_PROXY_URL -c https.proxy=$HTTPS_PROXY_URL -C $DIR pull 2>&1)
  fi
  if [ $? -ne 0 ]; then
    report_error log "Unable to update git $DIR: $OUT"
  fi

  new_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  if [ "$old_git_hash" != "$new_git_hash" ]; then
    CHANGE="Updated git repository in ${DIR} from commit $old_git_hash to $new_git_hash"
    CHANGES+="- $CHANGE\n"
    log "INFO" "$CHANGE"
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
for IMAGE in $(cat $PROJECT/docker-compose.yml ${OVERRIDE//-f/} | grep -v "^#" | grep "image:" | sed -e 's_^.*image: \(.*\).*$_\1_g; s_\"__g'); do
  log "INFO" "Checking for Updates of Image: $IMAGE"
  if docker pull $IMAGE | grep "Downloaded newer image"; then
    CHANGE="Image $IMAGE updated."
    CHANGES+="- $CHANGE\n"
    log "INFO" "$CHANGE"
    docker_updated="true"
  fi
done

# If anything is updated, restart service
if [ $git_updated = "true" ] || [ $docker_updated = "true" ]; then
  RES="Updates detected, now restarting bridgehead:\n$CHANGES"
  log "INFO" "$RES"
  hc_send log "$RES"
  sudo /bin/systemctl restart bridgehead@*.service
else
  RES="Nothing updated, nothing to restart."
  log "INFO" "$RES"
  hc_send log "$RES"
fi

if [ -n "${BACKUP_DIRECTORY}" ]; then
  if [ ! -d "$BACKUP_DIRECTORY" ]; then
    message="Performing automatic maintenance: Attempting to create backup directory $BACKUP_DIRECTORY."
    hc_send log "$message"
    log INFO "$message"
    mkdir -p "$BACKUP_DIRECTORY"
    chown -R "$BACKUP_DIRECTORY" bridgehead;
  fi
  checkOwner "$BACKUP_DIRECTORY" bridgehead || fail_and_report 1 "Automatic maintenance failed: Wrong permissions for backup directory $(pwd)"
  # Collect all container names that contain '-db'
  BACKUP_SERVICES="$(docker ps --filter name=-db --format "{{.Names}}" | tr "\n" "\ ")"
  log INFO "Performing automatic maintenance: Creating Backups for $BACKUP_SERVICES";
  for service in $BACKUP_SERVICES; do
    if [ ! -d "$BACKUP_DIRECTORY/$service" ]; then
      message="Performing automatic maintenance: Attempting to create backup directory for $service in $BACKUP_DIRECTORY."
      hc_send log "$message"
      log INFO "$message"
      mkdir -p "$BACKUP_DIRECTORY/$service"
    fi
    if createEncryptedPostgresBackup "$BACKUP_DIRECTORY" "$service"; then
      message="Performing automatic maintenance: Stored encrypted backup for $service in $BACKUP_DIRECTORY."
      hc_send log "$message"
      log INFO "$message"
    else
      fail_and_report 5 "Failed to create encrypted update for $service"
    fi
  done
else
  log WARN "Automated backups are disabled (variable AUTO_BACKUPS != \"true\")"
fi

exit 0

# TODO: Print last commit explicit
