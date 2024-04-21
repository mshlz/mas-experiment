#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

NET_NAME=mas-net
REDIS_NAME=mas-redis
APP_NAME=mas-app
LB_NAME=mas-lb
LB_PORT=3001

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
  ./scripts/app/docker_build_image.sh
fi

function spinAppInstance {
  if [ "$1" = "" ]; then
    local uniq="`date +%Y%m%d_%H%M%S`_`printf %.6s $RANDOM$RANDOM$RANDOM`"
  else
    local uniq=$1
  fi
  local name=${APP_NAME}_${uniq}
  if [ "$(docker ps -af name=$name -q)" = "" ]; then
    echo "creating app $name..."
    docker run -d --net $NET_NAME --net-alias $APP_NAME --hostname $name --rm --name $name $APP_NAME
  elif [ "$(docker ps -f name=$APP_NAME -q)" = "" ]; then
    echo "starting app $APP_NAME..."
    docker start $APP_NAME
  fi
}

spinAppInstance 1
# spinAppInstance 2 # run more instances, then check dns: docker exec mas-app_1 dig mas-app
# spinAppInstance 3


# check nginx lb
if [ "$(docker ps -af name=$LB_NAME -q)" = "" ]; then
  echo "creating lb $LB_NAME..."
  docker run -d --net $NET_NAME --name $LB_NAME --publish $LB_PORT:80 -v ./pkgs/lb/nginx/config/proxy.conf:/etc/nginx/nginx.conf -v ./pkgs/lb/nginx/logs:/var/log/nginx/ nginx:latest
elif [ "$(docker ps -f name=$LB_NAME -q)" = "" ]; then
  echo "starting lb $LB_NAME..."
  docker start $LB_NAME
fi