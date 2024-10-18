#!/bin/sh
#
#  90-provisioninginit.sh
#
#  Copyright (C) 2022 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

CONFIG_DEV=@CONFIG_DEV@
CONFIG_MOUNTPATH=@CONFIG_MOUNTPATH@

provisioninginit_enabled() {
	return 0
}

do_login() {
	sync
	setsid cttyhack /bin/login
}

provisioninginit_run() {
	ROOTFS_DIR=""
	if test -b ${CONFIG_DEV}; then
		msg "Mount ${CONFIG_DEV} to ${CONFIG_MOUNTPATH}"
		mkdir -p ${CONFIG_MOUNTPATH}
		mount ${CONFIG_DEV} ${CONFIG_MOUNTPATH}
	fi

	if [ $(lsmod | grep trusted | wc -l) -gt 0 ]; then
		rmmod trusted
	fi
	# Set kernel console loglevel
	LOGLEVEL="$(sysctl -n kernel.printk)"
	sysctl -q -w kernel.printk=4

	export PATH=/usr/sbin:/sbin:$PATH
	do_login
}
