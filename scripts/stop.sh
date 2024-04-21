#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

docker rm -f `docker ps -qf name=mas-app*` mas-redis mas-lb
docker network rm -f mas-net

if [ "$1" = "rmi" ]; then
  docker rmi -f mas-app
fi
