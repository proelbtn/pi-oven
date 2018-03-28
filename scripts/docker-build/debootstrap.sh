#!/bin/bash

set -e
cd $(dirname $0)/../..

mkdir -p /pi-oven

if [ ! -d /pi-oven/rootfs ]
then
    qemu-debootstrap --components=main,contrib,non-free \
            --arch armhf \
            --keyring lib/raspberrypi.gpg \
            stretch /pi-oven/rootfs http://mirrordirector.raspbian.org/raspbian/
fi

docker image build \
        -t pi-oven-debootstrap \
        -f docker/debootstrap/Dockerfile $@ /pi-oven
