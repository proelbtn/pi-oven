#!/bin/bash

set -e
cd $(dirname $0)/../..

if [ ! -d /tmp/rootfs ]
then
    qemu-debootstrap --components=main,contrib,non-free \
            --arch armhf \
            --keyring lib/raspberrypi.gpg \
            stretch /tmp/rootfs http://mirrordirector.raspbian.org/raspbian/
fi

docker image build \
        -t pi-oven-debootstrap \
        -f docker/debootstrap/Dockerfile /tmp