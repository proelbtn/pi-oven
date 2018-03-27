FROM pi-oven-bootstrap

# 00-configure-apt
COPY files/sources.list /etc/apt
COPY files/raspi.list /etc/apt/sources.list.d
RUN rm -f /etc/apt/apt.conf.d/51cache
COPY files/raspberrypi.gpg.key /tmp
RUN apt-key add /tmp/raspberrypi.gpg.key
RUN apt-get update
RUN apt-get dist-upgrade -y

# 01-locale
RUN debconf-set-selections locales locales/locales_to_be_generated multiselect en_GB.UTF-8 UTF-8
RUN debconf-set-selections locales locales/default_environment_locale select en_GB.UTF-8
RUN apt-get install -y locales

# 02-firmware
RUN apt-get install -y raspberrypi-bootloader