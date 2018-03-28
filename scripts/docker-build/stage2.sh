#!/bin/bash

set -e
cd $(dirname $0)/../..

docker image build \
        -t pi-oven-stage2 \
        -f docker/stage2/Dockerfile $@ docker/stage2