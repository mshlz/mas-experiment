#!/usr/bin/env bash
cd $(dirname $(readlink -f $0))
cd ..
WORKSPACE=$(pwd)

rm -rf $WORKSPACE/{,pkgs/app}/{.yarn,node_modules,build,*.log}

stop.sh
