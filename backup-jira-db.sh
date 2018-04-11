#!/bin/bash

set -x
set -e

# CID="hopeful_hermann"
CID=$(docker ps | awk '/atlassian-jira-software/ {print $1}')
echo "DEBUG: CID=${CID}"

DESTDIR='bk-itmgmacariow7-jira'

if [ ! -e "${DESTDIR}" ]; then
    mkdir "${DESTDIR}"
    cd "${DESTDIR}"
    git init
    cd -
fi

NOW=$(date '+%Y-%m-%d %H:%M:%S')
cd "${DESTDIR}"

# See https://github.com/nabeken/docker-volume-container-rsync
docker exec "${CID}" sh -c "id; id; du -sh data export"

# TODO: rsync -avz "${SOURCEDIR}" .
git add -A
git commit -m "Mirrored on ${NOW}

SOURCEDIR=${SOURCEDIR}"

# Fix file mode
find . -type f -exec chmod -x {} \;
git add -A
git commit -m "Fix file mode"

# EOF
