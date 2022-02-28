#!/bin/bash
# Ripper cron shell v1.0

# shellcheck disable=SC2006
current_state=`git pull`
if [ "$current_state" = "Already up to date." ]; then
    exit
else
    if cmp --silent -- "temp.txt" "urls.txt"; then
      echo "files contents are identical"
    else
      echo "files contents are not identical"
      docker_current_state=$(docker-compose down ; sh doit.sh -m light  ; docker-compose up)
      echo "$docker_current_state"
    fi
fi