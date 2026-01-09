#!/bin/sh
#
#  91-securebootinit.sh
#
#  Copyright (C) 2023 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

SKS_PATH=@SKS_PATH@
CONFIG_DEV=@CONFIG_DEV@
CONFIG_MOUNTPATH=@CONFIG_MOUNTPATH@

securestorageinit_enabled() {
	return 0
}

do_login() {
	export PATH=/usr/sbin:/sbin:$PATH
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

securestorageinit_run() {
	mkdir -p ${ROOTFS_DIR}

	# Set kernel console loglevel
	LOGLEVEL="$(sysctl -n kernel.printk)"
	sysctl -q -w kernel.printk=4

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
		#mmc or emmc => key example is in partition 3 and before in partition 1
		mkdir -p ${CONFIG_MOUNTPATH}
		mount ${CONFIG_DEV} ${CONFIG_MOUNTPATH}

		# go to login, when requested
		[ -n "${rescue}" ] && do_login

		if [ $(lsmod | grep trusted | wc -l) -gt 0 ]; then
			rmmod trusted
		fi
		#backward compatible to old first boot partition
		if ! test -d ${CONFIG_MOUNTPATH}/secrets; then
			umount ${CONFIG_MOUNTPATH}
			mount ${SKS_PATH} ${CONFIG_MOUNTPATH}
		fi
		if test -f ${CONFIG_MOUNTPATH}/secrets/trusted_key.config; then
			source ${CONFIG_MOUNTPATH}/secrets/trusted_key.config
			modprobe -q trusted source=${trustedsource}
		else
			modprobe -q trusted
		fi
		load_kernel_module encrypted-keys
		load_kernel_module dm-crypt
		load_kernel_module dm-integrity
		if test -f ${CONFIG_MOUNTPATH}/secrets/trusted_key.blob; then
			keyctl add trusted kmk "load `cat ${CONFIG_MOUNTPATH}/secrets/trusted_key.blob`" @u
		fi
		if test -f ${CONFIG_MOUNTPATH}/secrets/encrypted_key.blob; then
			keyctl add encrypted rootfs "load `cat ${CONFIG_MOUNTPATH}/secrets/encrypted_key.blob`" @u
		fi
		if test -f ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb; then
			caam-keygen import ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb importkey
			cat ${CONFIG_MOUNTPATH}/secrets/importkey | keyctl padd logon rootfs: @u
		fi

		# mount all partitions without label (sign for encrypted partition)
		count=$(ls ${root%?}* | wc -l)
		i=1
		j=0
		while [ $i -le $count ]
		do
			devroot=${root%?}${i}
			for arg in $(blkid ${devroot}); do
				case "${arg}" in
					LABEL=*) eval ${arg};;
					TYPE=*) eval ${arg};;
					PTTYPE=*) eval ${arg};;
				esac
			done

			if [ -n "${TYPE}" ] && [ "${TYPE}" = "DM_integrity" ]; then
				dm_inc_name=introot${j}
				integritysetup open ${devroot} --integrity sha256 --journal-integrity sha256 ${dm_inc_name}
				unset LABEL
				unset PTTYPE
				unset TYPE
				devroot=/dev/mapper/${dm_inc_name}
				for arg in $(blkid ${devroot}); do
					case "${arg}" in
						LABEL=*) eval ${arg};;
						TYPE=*) eval ${arg};;
						PTTYPE=*) eval ${arg};;
					esac
				done
			fi
			dm_enc_name=encroot${j}
			if [ ! -n "${TYPE}" ] && [ ! -n "${PTTYPE}" ]; then
				if test -f ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb; then
					dmsetup create ${dm_enc_name} --table "0 $(blockdev --getsz ${devroot}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${devroot} 0"
				else
					dmsetup create ${dm_enc_name} --table "0 $(blockdev --getsz ${devroot}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${devroot} 0"
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

		if [ -n "${bcactive}" ]; then
			dmvalue=${bcactive: -1}
			if [ -e /dev/mapper/introot0 ] && [ -e /dev/mapper/encroot0 ]; then
				dmvalue=1
				[ ${bcactive: -1} -eq 1 ] && dmvalue=3
			fi
		else
			dmvalue=0
			if [ -e /dev/mapper/introot0 ] && [ -e /dev/mapper/encroot0 ]; then
				dmvalue=1
			fi
		fi
		if [ $(ls /dev/dm-* | wc -l) -eq 0 ]; then
			printf "Unencrypted rootfs is not supported!\n"
			do_login
		else
			mount /dev/dm-${dmvalue} ${ROOTFS_DIR}
		fi
		umount ${CONFIG_MOUNTPATH}
	else
		# Net is not encrypted
		mount ${root} ${ROOTFS_DIR}
	fi
	mount --move /dev ${ROOTFS_DIR}/dev
	mount --move /proc ${ROOTFS_DIR}/proc
	mount --move /sys ${ROOTFS_DIR}/sys
	cd ${ROOTFS_DIR}
	exec switch_root ${ROOTFS_DIR} ${bootparam_init:-/sbin/init}
}
