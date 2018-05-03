#!/bin/bash
# =====================================================================
# Description: Backup JIRA database and attachments to a git repository
#
# Prerequisites:
# - Docker
# - Git
# - JIRA running inside a Docker container on the same host
# =====================================================================

# set -x
set -e

# JIRA_CID="hopeful_hermann"
JIRA_CID=$(docker ps | awk '/atlassian-jira-software/ {print $1}')
# echo "DEBUG: JIRA_CID=${JIRA_CID}"

DESTDIR="bk/$(hostname)"
# echo "DEBUG: DESTDIR=${DESTDIR}"

if [ ! -e "${DESTDIR}" ]; then
    echo "INFO: Creating git repository for backups at ${DESTDIR}"
    mkdir -p "${DESTDIR}"
    cd "${DESTDIR}"
    git init
    cd -
fi

NOW=$(date '+%Y-%m-%d %H:%M:%S')
cd "${DESTDIR}"
echo "INFO: ${0} started at ${NOW}"
echo "INFO: JIRA Backup directory: ${PWD}"

# docker exec "${JIRA_CID}" sh -c "id; pwd; du -sh data export"
docker exec "${JIRA_CID}" sh -c "tar cfz - data export" | tar xfz -

# TODO: See https://github.com/nabeken/docker-volume-container-rsync
# RSYNC_CID=$(docker run -d -p 10873:873 nabeken/docker-volume-container-rsync:latest)
# docker run -it --volumes-from ${RSYNC_CID} ubuntu /bin/bash
# TODO: rsync -avz "${SOURCEDIR}" .
# TODO: rsync rsync://<docker>:10873/
# TODO: rsync -avP /path/to/dir rsync://<docker>:10873/volume/
# ...
# docker stop ${RSYNC_CID}

find . -type f -exec chmod -x {} \;
git add -A
git commit -m "Created with backup-jira-db.sh

MIRROR_DATE=${NOW}
JIRA_CID=${JIRA_CID}
DESTDIR=${DESTDIR}"

# Fix file mode
find . -type f -exec chmod -x {} \;
git add -A
git commit -m "Fix file mode"

if [ git remote show | grep origin ]; then
    git push
fi
git status

# EOF
