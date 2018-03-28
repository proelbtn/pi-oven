FROM pi-oven-stage1

ENV ACTIVE_CONSOLES ""

# 00-copies-and-fills
RUN apt install -y raspi-copies-and-fills

# 01-sys-tweaks
# debconf
COPY files/debconf debconf
RUN debconf-set-selections debconf && \
    rm -rf debconf
# packages-nr
RUN apt-get install -y --no-install-recommends cifs-utils
# packages
RUN apt-get install -y ssh less fbset sudo psmisc strace ed ncdu crda \
    console-setup keyboard-configuration debconf-utils parted unzip \
    build-essential manpages-dev python bash-completion gdb pkg-config \
    python-rpi.gpio v4l-utils avahi-daemon lua5.1 luajit hardlink ca-certificates curl \
    fake-hwclock nfs-common usbutils libraspberrypi-dev libraspberrypi-doc libfreetype6-dev \
    dosfstools dphys-swapfile raspberrypi-sys-mods pi-bluetooth apt-listchanges \
    usb-modeswitch apt-transport-https libpam-chksshpwd rpi-update libmtp-runtime \
    rsync htop man-db policykit-1
# patch
COPY files/useradd /etc/default
COPY files/dphys-swapfile /etc
COPY files/inputrc /etc
COPY files/login.defs /etc
COPY files/profile /etc
COPY files/rc.local /etc
COPY files/cmdline.txt /boot
# run
COPY files/resize2fs_once /etc/init.d
RUN mkdir /etc/systemd/system/rc-local.service.d
COPY files/ttyoutput.conf /etc/systemd/system/rc-local.service.d
COPY files/50raspi /etc/apt/apt.conf.d
COPY files/console-setup /etc/default
COPY files/rc.local /etc
RUN systemctl disable hwclock.sh
RUN systemctl disable nfs-common
RUN systemctl disable rpcbind
RUN systemctl disable ssh
RUN systemctl enable regenerate_ssh_host_keys
RUN systemctl enable resize2fs_once
RUN for GRP in input spi i2c gpio; do \
        groupadd -f -r "$GRP"; \
    done
RUN for GRP in adm dialout cdrom audio users sudo video games plugdev input gpio spi i2c netdev; do \
        adduser pi $GRP; \
    done
RUN setupcon --force --save-only -v
RUN usermod --pass='*' root
RUN rm -rf /etc/ssh/ssh_host_*_key*

# 02-net-tweaks
RUN apt-get update
RUN apt-get install -y wpasupplicant wireless-tools firmware-atheros \
    firmware-brcm80211 firmware-libertas firmware-misc-nonfree \
    firmware-realtek raspberrypi-net-mods dhcpcd5 net-tools
RUN mkdir -p /etc/systemd/system/dhcpcd.service.d
COPY files/wait.conf /etc/systemd/system/dhcpcd.service.d
RUN mkdir -p /etc/wpa_supplicant
COPY files/wpa_supplicant.conf /etc/wpa_supplicant