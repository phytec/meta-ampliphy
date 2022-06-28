#!/bin/sh
#
#  90-provisioninginit.sh
#
#  Copyright (C) 2022 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#

SKS_PATH=@SKS_PATH@
SKS_MOUNTPATH=@SKS_MOUNTPATH@

provisioninginit_enabled() {
	return 0
}

do_login() {
	sync
	setsid cttyhack /bin/login
}

provisioninginit_run() {
	ROOTFS_DIR=""
	if test -b ${SKS_PATH}; then
		msg "Mount ${SKS_PATH} to ${SKS_MOUNTPATH}"
		mkdir -p ${SKS_MOUNTPATH}
		mount ${SKS_PATH} ${SKS_MOUNTPATH}
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
