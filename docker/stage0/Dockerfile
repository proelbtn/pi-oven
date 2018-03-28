FROM pi-oven-debootstrap

ENV DEBIAN_FRONTEND=noninteractive
# https://bugs.launchpad.net/nexenta/+bug/335056
RUN chown -R man /var/cache/man

# 00-configure-apt
COPY files/sources.list /etc/apt
COPY files/raspi.list /etc/apt/sources.list.d
RUN rm -f /etc/apt/apt.conf.d/51cache
COPY files/raspberrypi.gpg.key /tmp
RUN apt-key add /tmp/raspberrypi.gpg.key
RUN apt-get update
RUN apt-get dist-upgrade -y

# 01-locale
COPY files/debconf debconf
RUN debconf-set-selections debconf && \
    rm -rf debconf
RUN apt-get install -y locales

# 02-firmware
RUN apt-get install -y raspberrypi-bootloader