FROM pi-oven-stage0

# 00-boot-files
COPY files/cmdline.txt /boot
COPY files/config.txt /boot

# 01-sys-tweaks
COPY files/bashrc /etc/skel/.bashrc
RUN mkdir -p /etc/systemd/system/getty@tty1.service.d
COPY files/noclear.conf /etc/systemd/system/getty@tty1.service.d/noclear.conf
COPY files/fstab /etc/fstab
RUN if ! id -u pi >/dev/null 2>&1; then adduser --disabled-password --gecos "" pi; fi
RUN echo "pi:raspberry" | chpasswd
RUN echo "root:root" | chpasswd

# 02-net-tweaks
COPY files/hosts /etc
COPY files/ipv6.conf /etc/modprobe.d/ipv6.conf
COPY files/hostname /etc/hostname
RUN ln -sf /dev/null /etc/systemd/network/99-default.link

# 03-install-packages
RUN apt install -y libraspberrypi-bin libraspberrypi0 raspi-config