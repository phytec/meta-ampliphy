#!/bin/sh
#
#  securestorage-init.sh
#
#  Copyright (C) 2021 PHYTEC Messtechnik GmbH,
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

# Load kernel module
# $1 file name
load_kernel_module() {
	MODEXIST=$(find /lib/modules/$(uname -r) -type f -name "$1.ko*")
	if [ -f "$MODEXIST" ]; then
		modprobe $1
	fi
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

	load_kernel_module tpm_tis_spi
	# go to login, when requested
	[ -n "${rescue}" ] && do_login

	if test -f /mnt_secrets/secrets/trusted_key.config; then
		source /mnt_secrets/secrets/trusted_key.config
		modprobe -q  trusted source=${trustedsource}
	else
		modprobe -q  trusted
	fi
	load_kernel_module encrypted-keys
	load_kernel_module dm-crypt
	load_kernel_module dm-integrity

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
				 TYPE=*) eval ${arg};;
				 PTTYPE=*) eval ${arg};;
			esac
		done

		devroot=${root%?}${i}
		if [ ! -n "${LABEL}" ] &&  [ -n "${TYPE}" ] && [ "${TYPE}" = "DM_integrity" ]; then
			integritysetup open ${devroot} --integrity sha256 --journal-integrity sha256 introot${j}
			unset LABEL
			unset PTTYPE
			devroot=/dev/mapper/introot${j}
			for arg in $(blkid ${devroot}); do
				case "${arg}" in
					LABEL=*) eval ${arg};;
					PTTYPE=*) eval ${arg};;
				esac
			done
		fi
		if [ ! -n "${LABEL}" ] && [ ! -n "${PTTYPE}" ]; then
			if test -f /mnt_secrets/secrets/tksecure_key.bb; then
				dmsetup create root${j} --table "0 $(blockdev --getsz ${devroot}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${devroot} 0"
			else
				dmsetup create root${j} --table "0 $(blockdev --getsz ${devroot}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${devroot} 0"
			fi
			let j=j+1
		else
			[ -n "${TYPE}" ] && [ "${TYPE}" = "DM_integrity" ] && let j=j+1
		fi
		let i=i+1
		unset LABEL
		unset TYPE
		unset PTTYPE
	done
	dmvalue=0
	if [ -n "${bcactive}" ]; then
		dmvalue=${bcactive: -1}
		if [ $(ls /dev/dm-* | wc -l) -eq 4 ]; then
			dmvalue=1
			[ ${bcactive: -1} -eq 1 ] && dmvalue=3
		fi
	fi
	if [ $(ls /dev/dm-* | wc -l) -eq 0 ]; then
		mount ${root} /newroot
	else
		mount /dev/dm-${dmvalue} /newroot
	fi
	umount /mnt_secrets
else
	# Net is not encrypted
	mount ${root} /newroot
fi

mount --move /dev /newroot/dev
umount /sys /proc
exec switch_root /newroot ${init:-/sbin/init}
