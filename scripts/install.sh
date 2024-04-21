#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

# install app package.json
yarn --cwd $WORKSPACE/pkgs/app install