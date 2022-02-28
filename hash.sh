#!/bin/bash
# Ripper cron shell v1.0

commandos="docker-compose down ; sh doit.sh -m light  ; docker-compose up"

current_state=`git pull`
if [ "$current_state" = "Already up to date." ]; then
    exit
else
    printf "${GREEN}Deployed!\n${RC}"
fi

if cmp --silent -- "temp.txt" "urls.txt"; then
  echo "files contents are identical"
else
  curl https://api.telegram.org/bot162717732:AAFM1QiEiRMTYuVhal17vxg-mJHZ3FJBRWo/sendMessage?chat_id=@smsnotif&text="$current_state"
  $commandos
fi