#!/bin/sh
#
#  secureboot-fileencrypt
#
#  Copyright (C) 2020 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

POWEROFF_TIME="10"

set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[ERROR] Key and Filesystem Initialization" 1>&2
		printf "\nThe system will poweroff in %s seconds" "${POWEROFF_TIME}"
		sleep "${POWEROFF_TIME}"
		sync && poweroff -f
		exit 0
	fi
}

do_login() {
	sync
	setsid cttyhack /bin/login
}

# Main
#------------------------------------------------------------------------------

mkdir -p /proc /sys /dev /mnt_secrets /newroot
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Set kernel console loglevel
LOGLEVEL="$(sysctl -n kernel.printk)"
sysctl -q -w kernel.printk=4

export PATH=/usr/sbin:/sbin:$PATH

for arg in $(cat /proc/cmdline); do
	case "${arg}" in
	rescue=1|root=*|rootfstype=*) eval ${arg};;
	esac
	if echo ${arg} | grep -q "ubi.mtd"; then
		ubimtd=$(echo ${arg##*ubi.mtd=})
	fi
	if echo ${arg} | grep -q "bootchooser.active"; then
		bcactive=$(echo ${arg##*bootchooser.active=})
	fi
	if echo ${arg} | grep -q "rauc.slot"; then
		bcactive=$(echo ${arg##*rauc.slot=})
	fi
done

# Translate "PARTUUID=..." to real device
root="$(findfs ${root})"

# go to login, when ubifs
if [ "${rootfstype}" == "ubifs" ]; then
	printf "Please use FITImage without ramdisk for ubifs!\n"
	do_login
fi

if echo "$root" | grep -q "mmc"; then
	#mmc or emmc => key example is in partition 1
	mount ${root%?}1 /mnt_secrets

	mkdir -p /mnt_secrets/secrets

	# go to login, when requested
	[ -n "${rescue}" ] && do_login

	if test -f /mnt_secrets/secrets/trusted_key.blob; then
		keyctl add trusted kmk  "load `cat /mnt_secrets/secrets/trusted_key.blob`" @u
	fi
	if test -f /mnt_secrets/secrets/encrypted_key.blob; then
		keyctl add encrypted rootfs  "load `cat /mnt_secrets/secrets/encrypted_key.blob`" @u
	fi
	if test -f /mnt_secrets/secrets/tksecure_key.bb; then
		caam-keygen import /mnt_secrets/secrets/tksecure_key.bb importkey
		cat /mnt_secrets/secrets/importkey | keyctl padd logon rootfs: @u
	fi
	# mount all partitions without label (sign for encrypted partition)
	count=$(ls ${root%?}* | wc -l)
	i=1
	j=0
	while [ $i -le $count ]
	do
		for arg in $(blkid ${root%?}${i}); do
			case "${arg}" in
				 LABEL=*) eval ${arg};;
			esac
		done
		if [ ! -n "${LABEL}" ]; then
			if test -f /mnt_secrets/secrets/tksecure_key.bb; then
				dmsetup create root${j} --table "0 $(blockdev --getsz ${root%?}${i}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${root%?}${i} 0"
			else
				dmsetup create root${j} --table "0 $(blockdev --getsz ${root%?}${i}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${root%?}${i} 0"
			fi
			let j=j+1
		fi
		let i=i+1
		unset LABEL
	done
	if [ -n "${bcactive}" ]; then
		mount /dev/dm-${bcactive: -1} /newroot
	else
		mount /dev/dm-0 /newroot
	fi
	umount /mnt_secrets
else
	# Net is not encrypted
	mount ${root} /newroot
fi

mount --move /dev /newroot/dev
umount /sys /proc
exec switch_root /newroot ${init:-/sbin/init}
