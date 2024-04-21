#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

# install root package.json
yarn

# install app package.json
yarn --cwd $WORKSPACE/app install