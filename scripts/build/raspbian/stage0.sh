#!/bin/bash

set -e
cd $(dirname $0)/../../..

docker image build \
        -t raspbian:stage0 \
        -f docker/raspbian/stage0/Dockerfile $@ docker/raspbian/stage0