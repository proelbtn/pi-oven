#!/bin/bash

set -e
cd $(dirname $0)/../..

docker image build \
        -t pi-oven-stage1 \
        -f docker/stage1/Dockerfile docker/stage1