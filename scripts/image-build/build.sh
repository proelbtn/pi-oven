#!/bin/bash -e

cd $(dirname $0)/../..

unmount_image(){
	sync
	sleep 1
	local LOOP_DEVICES
	LOOP_DEVICES=$(losetup -j "${1}" | cut -f1 -d':')
	for LOOP_DEV in ${LOOP_DEVICES}; do
		if [ -n "${LOOP_DEV}" ]; then
			local MOUNTED_DIR
			MOUNTED_DIR=$(mount | grep "$(basename "${LOOP_DEV}")" | head -n 1 | cut -f 3 -d ' ')
			if [ -n "${MOUNTED_DIR}" ] && [ "${MOUNTED_DIR}" != "/" ]; then
				unmount "$(dirname "${MOUNTED_DIR}")"
			fi
			sleep 1
			losetup -d "${LOOP_DEV}"
		fi
	done
}

IMG_FILE="/tmp/raspberrypi.img"

unmount_image "/tmp/raspberrypi.img"
rm -f "/tmp/raspberrypi.img"

rm -rf "build"
mkdir -p "build"

BOOT_SIZE=$(du --apparent-size -s "/tmp/rootfs/boot" --block-size=1 | cut -f 1)
TOTAL_SIZE=$(du --apparent-size -s "/tmp/rootfs" --exclude var/cache/apt/archives --block-size=1 | cut -f 1)

ROUND_SIZE="$((4 * 1024 * 1024))"       # 4MB
ROUNDED_ROOT_SECTOR=$(((2 * BOOT_SIZE + ROUND_SIZE) / ROUND_SIZE * ROUND_SIZE / 512 + 8192))
IMG_SIZE=$(((BOOT_SIZE + TOTAL_SIZE + (800 * 1024 * 1024) + ROUND_SIZE - 1) / ROUND_SIZE * ROUND_SIZE))

truncate -s "${IMG_SIZE}" "/tmp/raspberrypi.img"
fdisk -H 255 -S 63 "/tmp/raspberrypi.img" <<EOF
o
n


8192
+$((BOOT_SIZE * 2 /512))
p
t
c
n


${ROUNDED_ROOT_SECTOR}


p
w
EOF

PARTED_OUT=$(parted -s "/tmp/raspberrypi.img" unit b print)
BOOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 1'| xargs echo -n | cut -d" " -f 2 | tr -d B)
BOOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 1'| xargs echo -n | cut -d" " -f 4 | tr -d B)
ROOT_OFFSET=$(echo "$PARTED_OUT" | grep -e '^ 2'| xargs echo -n | cut -d" " -f 2 | tr -d B)
ROOT_LENGTH=$(echo "$PARTED_OUT" | grep -e '^ 2'| xargs echo -n | cut -d" " -f 4 | tr -d B)

BOOT_DEV=$(losetup --show -f -o "${BOOT_OFFSET}" --sizelimit "${BOOT_LENGTH}" "${IMG_FILE}")
ROOT_DEV=$(losetup --show -f -o "${ROOT_OFFSET}" --sizelimit "${ROOT_LENGTH}" "${IMG_FILE}")
echo "/boot: offset $BOOT_OFFSET, length $BOOT_LENGTH"
echo "/:     offset $ROOT_OFFSET, length $ROOT_LENGTH"

ROOT_FEATURES="^huge_file"
for FEATURE in metadata_csum 64bit; do
	if grep -q "$FEATURE" /etc/mke2fs.conf; then
	    ROOT_FEATURES="^$FEATURE,$ROOT_FEATURES"
	fi
done
mkdosfs -n boot -F 32 -v "$BOOT_DEV" > /dev/null
mkfs.ext4 -L rootfs -O "$ROOT_FEATURES" "$ROOT_DEV" > /dev/null

rm -rf "/tmp/mnt"
mkdir -p "/tmp/mnt"
mount -v "$ROOT_DEV" "/tmp/mnt" -t ext4
mkdir -p "/tmp/mnt/boot"
mount -v "$BOOT_DEV" "/tmp/mnt/boot" -t vfat

docker container run --rm -v /tmp/mnt:/.mnt -w "/" -h raspberrypi $1 \
	rsync -aHAXx --exclude var/cache/apt/archives --exclude .mnt "/" "/.mnt/" 2>/dev/null

IMGID="$(dd if="/tmp/raspberrypi.img" skip=440 bs=1 count=4 2>/dev/null | xxd -e | cut -f 2 -d' ')"

BOOT_PARTUUID="${IMGID}-01"
ROOT_PARTUUID="${IMGID}-02"

sed -i "s/stretch main ui staging/stretch main ui/" "/tmp/mnt/etc/apt/sources.list.d/raspi.list"

echo "namespace 8.8.8.8" > "/tmp/mnt/etc/resolv.conf"

sed -i "s/BOOTDEV/PARTUUID=${BOOT_PARTUUID}/" "/tmp/mnt/etc/fstab"
sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "/tmp/mnt/etc/fstab"

sed -i "s/ROOTDEV/PARTUUID=${ROOT_PARTUUID}/" "/tmp/mnt/boot/cmdline.txt"

if [ -d "/tmp/mnt/home/pi/.config" ]; then
	chmod 700 "/tmp/mnt/home/pi/.config"
fi

rm -f "/tmp/mnt/etc/apt/apt.conf.d/51cache"
rm -f "/tmp/mnt/usr/bin/qemu-arm-static"

rm -f "/tmp/mnt/etc/apt/sources.list~"
rm -f "/tmp/mnt/etc/apt/trusted.gpg~"

rm -f "/tmp/mnt/etc/passwd-"
rm -f "/tmp/mnt/etc/group-"
rm -f "/tmp/mnt/etc/shadow-"
rm -f "/tmp/mnt/etc/gshadow-"

rm -f "/tmp/mnt/var/cache/debconf/*-old"
rm -f "/tmp/mnt/var/lib/dpkg/*-old"

rm -f "/tmp/mnt/usr/share/icons/*/icon-theme.cache"

rm -f "/tmp/mnt/var/lib/dbus/machine-id"

true > "/tmp/mnt/etc/machine-id"

ln -nsf /proc/mounts "/tmp/mnt/etc/mtab"

find "/tmp/mnt/var/log/" -type f -exec cp /dev/null {} \;

rm -f "/tmp/mnt/root/.vnc/private.key"
rm -f "/tmp/mnt/etc/vnc/updateid"

install lib/LICENSE.oracle "/tmp/mnt/boot/"


ROOT_DEV="$(mount | grep "/tmp/mnt " | cut -f1 -d' ')"

umount -R "/tmp/mnt"
zerofree -v "${ROOT_DEV}"

unmount_image "/tmp/raspberrypi.img"