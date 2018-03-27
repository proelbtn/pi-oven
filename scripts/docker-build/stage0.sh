#!/bin/bash

set -e
cd $(dirname $0)/../..

docker image build \
        -t pi-oven-stage0 \
        -f docker/stage0/Dockerfile docker/stage0