#!/bin/sh
#
#  securestorage-provisioning-init.sh
#
#  Copyright (C) 2022 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

POWEROFF_TIME="10"
SKS_PATH=@SKS_PATH@
SKS_MOUNTPATH=@SKS_MOUNTPATH@

set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[Initialization ERROR] The system will poweroff in %s seconds" "${POWEROFF_TIME}" 1>&2
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

mkdir -p /proc /sys /dev /newroot
mount -t proc proc /proc
mount -t sysfs sysfs /sys
mount -t devtmpfs devtmpfs /dev

# Set kernel console loglevel
LOGLEVEL="$(sysctl -n kernel.printk)"
sysctl -q -w kernel.printk=4

export PATH=/usr/sbin:/sbin:$PATH

load_kernel_module tpm_tis_spi

if test -b ${SKS_PATH}; then
	printf "\nMount ${SKS_PATH} to ${SKS_MOUNTPATH} \n" 1>&2
	mkdir -p ${SKS_MOUNTPATH}
	mount ${SKS_PATH} ${SKS_MOUNTPATH}
fi

do_login
