#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ../..
WORKSPACE=$(pwd)
COMMIT=$(git rev-parse --verify HEAD)

cd $WORKSPACE/pkgs/app

rm -rf build &&
yarn build &&
jq -r --arg commit $COMMIT '.commit = $commit' package.json > build/package.json &&
cp -a yarn.lock tsconfig.json node_modules build &&
cd build &&
docker build -t mas-app . -f ../Dockerfile
