#!/bin/bash

if [ $# != 1 ]; then
    echo "./post_build.sh [image name]"
    exit 1
fi

cd $(dirname $0)/../..

cp /tmp/raspberrypi.img build/$1