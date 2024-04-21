#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

docker rm -f mas-app mas-redis mas-lb
docker network rm -f mas-net
