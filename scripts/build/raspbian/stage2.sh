#!/bin/bash

set -e
cd $(dirname $0)/../../..

docker image build \
        -t raspbian:stage2 \
        -f docker/raspbian/stage2/Dockerfile $@ docker/raspbian/stage2