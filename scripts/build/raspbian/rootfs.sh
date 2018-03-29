#!/bin/bash

if [ "$(id | grep 'uid=0(root)')" = "" ]; then
    echo "This command requires the privileged operations"
    exit 1
fi

set -e
cd $(dirname $0)/../../..

mkdir -p /opt/raspbian

if [ ! -d /opt/raspbian/rootfs ]
then
    qemu-debootstrap --components=main,contrib,non-free \
            --arch armhf \
            --keyring lib/raspberrypi.gpg \
            stretch /opt/raspbian/rootfs http://mirrordirector.raspbian.org/raspbian/
fi

docker image build \
        -t raspbian:rootfs \
        -f docker/raspbian/rootfs/Dockerfile $@ /opt/raspbian
