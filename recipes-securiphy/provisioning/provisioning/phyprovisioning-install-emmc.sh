#!/bin/sh
#
#  provisioning-emmc.sh
#
#  Copyright (C) 2022 PHYTEC Messtechnik GmbH,
#  Author: Maik Otto <m.otto@phytec.de>
#
#  Released under the MIT license (see COPYING.MIT for the terms)
#
set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[ERROR] Provisioning eMMC install" 1>&2
		exit $?
	fi
}

version="v0.5"
SKS_PATH=@SKS_PATH@
SKS_MOUNTPATH=@SKS_MOUNTPATH@
SKS_SECRETFOLDER=@SKS_SECRETFOLDER@
FLASH_PATH=${SKS_PATH%??}
FILE_SYSTEM=""
CONFIG_DEV=@CONFIG_DEV@
CONFIG_MOUNTPATH=@CONFIG_MOUNTPATH@

usage="
PHYTEC Install Script ${version} for eMMC

Usage:  $(basename $0) [PARAMETER] [ACTION]

Example:
    $(basename $0) --filesystem /media/phytec-security-image.rootfs.partup --newemmc

One of the following action can be selected:
    -n | --newemmc    Copy filesystem image to eMMC

The following PARAMETER must be set for eMMC provisioning:
    -p | --flashpath <flash device> = ${FLASH_PATH}
    -s | --filesystem <path to sdcard image or partup file>
"


#
# Command line options
#
ARGS=$(getopt -n $(basename $0) -o p:s:nvh -l flashpath:,filesystem:,newemmc,version,help -- "$@")
VALID_ARGS=$?
if [ "$VALID_ARGS" != "0" ]; then
	echo "${usage}"
	exit 2
fi

eval set -- "$ARGS"
while :
do
	case ${1} in
	-p | --flashpath) FLASH_PATH="${2}"; shift 2;;
	-s | --filesystem) FILE_SYSTEM="${2}"; shift 2;;
	-n | --newemmc)
		if [ -z "${FLASH_PATH}" ] || [ -z "${FILE_SYSTEM}" ]; then
			echo "Set flash path and filesystem first!"
			exit 4
		fi
		mountpoint -q "${SKS_MOUNTPATH}" && umount -q "${SKS_MOUNTPATH}"
		mountpoint -q "${CONFIG_MOUNTPATH}" && umount -q "${CONFIG_MOUNTPATH}"
		filename=$(basename "${FILE_SYSTEM}")
		if [ "${filename##*.}" = "partup" ]; then
			partup install ${FILE_SYSTEM} ${FLASH_PATH}
			mkdir -p /media/data_partup
			mount -t squashfs ${FILE_SYSTEM} /media/data_partup
		else
			dd if=${FILE_SYSTEM} of=${FLASH_PATH} bs=100M
			sync
			partprobe ${FLASH_PATH}
		fi
		mkdir -p ${SKS_MOUNTPATH}
		mount ${SKS_PATH} ${SKS_MOUNTPATH}
		mkdir -p ${SKS_MOUNTPATH}${SKS_SECRETFOLDER}
		mkdir -p ${CONFIG_MOUNTPATH}
		mount ${CONFIG_DEV} ${CONFIG_MOUNTPATH}
		exit 0
		;;
	-h | --help)
		echo "${usage}"
		exit 0
		;;
	-v | --version)
		echo "${version}"
		exit 0
		;;
	*)
		echo "Unknown Parameter or Action"
		echo "${usage}"
		exit 2
	esac
done
