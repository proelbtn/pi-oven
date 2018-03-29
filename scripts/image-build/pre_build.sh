#!/bin/bash

if [ $# != 1 ]; then
    echo "./pre_build.sh [container id]"
    exit 1
fi

cd $(dirname $0)/../..

echo "Exporting rootfs from docker..."
DOCKER_CID="$(docker container run -d $1 /bin/false)"
docker export -o /tmp/rootfs.tar ${DOCKER_CID}

echo "Deleting old rootfs folder..."
rm -rf /tmp/rootfs

echo "Creating new rootfs folder..."
mkdir -p /tmp/rootfs
pushd /tmp/rootfs; tar xfv /tmp/rootfs.tar; popd > /dev/null

echo "Deleting container"
docker container rm -f ${DOCKER_CID}