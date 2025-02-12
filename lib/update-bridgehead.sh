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

CONFFILE=/etc/bridgehead/$PROJECT.conf

if [ ! -e $CONFFILE ]; then
  fail_and_report 1 "Configuration file $CONFFILE not found."
fi

source $CONFFILE

assertVarsNotEmpty SITE_ID || fail_and_report 1 "Update failed: SITE_ID empty"
export SITE_ID

checkOwner /srv/docker/bridgehead bridgehead || fail_and_report 1 "Update failed: Wrong permissions in /srv/docker/bridgehead"
checkOwner /etc/bridgehead bridgehead || fail_and_report 1 "Update failed: Wrong permissions in /etc/bridgehead"

# Use Secret Sync to validate the GitLab token in /var/cache/bridgehead/secrets/gitlab_token.
# If it is missing or expired, Secret Sync will create a new token and write it to the file.
# The git credential helper reads the token from the file during git pull.
mkdir -p /var/cache/bridgehead/secrets
touch /var/cache/bridgehead/secrets/gitlab_token # the file has to exist to be mounted correctly in the Docker container
log "INFO" "Running Secret Sync for the GitLab token"
docker pull docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest # make sure we have the latest image
docker run --rm \
  -v /var/cache/bridgehead/secrets/gitlab_token:/usr/local/cache \
  -v $PRIVATEKEYFILENAME:/run/secrets/privkey.pem:ro \
  -v /srv/docker/bridgehead/$PROJECT/root.crt.pem:/run/secrets/root.crt.pem:ro \
  -v /etc/bridgehead/trusted-ca-certs:/conf/trusted-ca-certs:ro \
  -e TLS_CA_CERTIFICATES_DIR=/conf/trusted-ca-certs \
  -e NO_PROXY=localhost,127.0.0.1 \
  -e ALL_PROXY=$HTTPS_PROXY_FULL_URL \
  -e PROXY_ID=$PROXY_ID \
  -e BROKER_URL=$BROKER_URL \
  -e GITLAB_PROJECT_ACCESS_TOKEN_PROVIDER=secret-sync-central.oidc-client-enrollment.$BROKER_ID \
  -e SECRET_DEFINITIONS=GitLabProjectAccessToken:BRIDGEHEAD_CONFIG_REPO_TOKEN: \
  docker.verbis.dkfz.de/cache/samply/secret-sync-local:latest
if [ $? -eq 0 ]; then
  log "INFO" "Secret Sync was successful"
  # In the past we used to hardcode tokens into the repository URL. We have to remove those now for the git credential helper to become effective.
  CLEAN_REPO="$(git -C /etc/bridgehead remote get-url origin | sed -E 's|https://[^@]+@|https://|')"
  git -C /etc/bridgehead remote set-url origin "$CLEAN_REPO"
  # Set the git credential helper
  git -C /etc/bridgehead config credential.helper /srv/docker/bridgehead/lib/gitlab-token-helper.sh
else
  log "WARN" "Secret Sync failed"
  # Remove the git credential helper
  git -C /etc/bridgehead config --unset credential.helper
fi

# In the past the git credential helper was also set for /srv/docker/bridgehead but never used.
# Let's remove it to avoid confusion. This line can be removed at some point the future when we
# believe that it was removed on all/most production servers.
git -C /srv/docker/bridgehead config --unset credential.helper

CHANGES=""

# Check git updates
git_updated="false"
for DIR in /etc/bridgehead $(pwd); do
  log "INFO" "Checking for updates to git repo $DIR ..."
  OUT="$(git -C $DIR status --porcelain)"
  if [ -n "$OUT" ]; then
    report_error log "The working directory $DIR is modified. Changed files: $OUT"
  fi
  old_git_hash="$(git -C $DIR rev-parse --verify HEAD)"
  if [ -z "$HTTPS_PROXY_FULL_URL" ]; then
    log "INFO" "Git is using no proxy!"
    OUT=$(retry 5 git -C $DIR fetch 2>&1 && retry 5 git -C $DIR pull 2>&1)
  else
    log "INFO" "Git is using proxy ${HTTPS_PROXY_URL} from ${CONFFILE}"
    OUT=$(retry 5 git -c http.proxy=$HTTPS_PROXY_FULL_URL -c https.proxy=$HTTPS_PROXY_FULL_URL -C $DIR fetch 2>&1 && retry 5 git -c http.proxy=$HTTPS_PROXY_FULL_URL -c https.proxy=$HTTPS_PROXY_FULL_URL -C $DIR pull 2>&1)
  fi
  if [ $? -ne 0 ]; then
    OUT_SAN=$(echo $OUT | sed -E 's|://[^:]+:[^@]+@|://credentials@|g')
    report_error log "Unable to update git $DIR: $OUT_SAN"
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
for IMAGE in $($COMPOSE -p $PROJECT -f ./minimal/docker-compose.yml -f ./$PROJECT/docker-compose.yml $OVERRIDE config | grep "image:" | sed -e 's_^.*image: \(.*\).*$_\1_g; s_\"__g'); do
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
  checkOwner "$BACKUP_DIRECTORY" bridgehead || fail_and_report 1 "Automatic maintenance failed: Wrong permissions for backup directory $BACKUP_DIRECTORY"
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

#TODO: the following block can be deleted after successful update at all sites
if [ ! -z "$LDM_PASSWORD" ]; then
  FILE="/etc/bridgehead/$PROJECT.local.conf"
  log "INFO" "Migrating LDM_PASSWORD to encrypted credentials in $FILE"
  add_basic_auth_user $PROJECT $LDM_PASSWORD "LDM_AUTH" $PROJECT
  add_basic_auth_user $PROJECT $LDM_PASSWORD "NNGM_AUTH" $PROJECT
  sed -i "/LDM_PASSWORD/{d;}" $FILE
fi

exit 0

# TODO: Print last commit explicit
