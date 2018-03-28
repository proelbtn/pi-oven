#!/bin/bash

# Requirement
apt update
apt install -y \
    apt-transport-https ca-certificates \
    curl software-properties-common debootstrap qemu-user-static

# Docker CE
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt update
apt-get install -y docker-ce

# for Docker
gpasswd -a vagrant docker