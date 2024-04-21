#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

NET_NAME=mas-net
REDIS_NAME=mas-redis
APP_NAME=mas-app

# check if network is already created, otherwise create it
if [ "$(docker network ls -f name=$NET_NAME -q)" = "" ]; then
  echo "creating network $NET_NAME..."
  docker network create $NET_NAME
fi

# check redis
if [ "$(docker ps -af name=$REDIS_NAME -q)" = "" ]; then
  echo "creating redis $REDIS_NAME..."
  docker run -d --net $NET_NAME --hostname $REDIS_NAME --name $REDIS_NAME redis:alpine
elif [ "$(docker ps -f name=$REDIS_NAME -q)" = "" ]; then
  echo "starting redis $REDIS_NAME..."
  docker start $REDIS_NAME
fi

# check app image
if [ "$(docker images -f reference=$APP_NAME -q)" = "" ]; then
  echo "creating app image $APP_NAME..."
  app/docker_build_image.sh
fi

if [ "$(docker ps -af name=$APP_NAME -q)" = "" ]; then
  echo "creating app $APP_NAME..."
  docker run -d --net $NET_NAME --net-alias $APP_NAME --hostname $APP_NAME --name $APP_NAME --publish 3001:3001 $APP_NAME
elif [ "$(docker ps -f name=$APP_NAME -q)" = "" ]; then
  echo "starting app $APP_NAME..."
  docker start $APP_NAME
fi