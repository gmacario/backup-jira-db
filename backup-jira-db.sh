#!/bin/bash

set -x
set -e

# JIRA_CID="hopeful_hermann"
JIRA_CID=$(docker ps | awk '/atlassian-jira-software/ {print $1}')
echo "DEBUG: JIRA_CID=${JIRA_CID}"

DESTDIR='bk-itmgmacariow7-jira'

if [ ! -e "${DESTDIR}" ]; then
    mkdir "${DESTDIR}"
    cd "${DESTDIR}"
    git init
    cd -
fi

NOW=$(date '+%Y-%m-%d %H:%M:%S')
cd "${DESTDIR}"

docker exec "${JIRA_CID}" sh -c "id; id; du -sh data export"

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
git commit -m "Mirrored on ${NOW}

SOURCEDIR=${SOURCEDIR}"

# Fix file mode
find . -type f -exec chmod -x {} \;
git add -A
git commit -m "Fix file mode"

# EOF
