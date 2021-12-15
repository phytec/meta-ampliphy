#!/bin/sh

set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[ERROR] Secure Storage install" 1>&2
		exit $?
	fi
}

version="v1.1"
usage="
PHYTEC Install Script ${version} for Secure Storage

Usage:  $(basename $0) [PARAMETER] [ACTION]

Example:
    $(basename $0) --flashpath /dev/mmcblk0
    --filesystem /media/phytec-security-image.tgz --rauc
    --flashlayout 5,6
    --newsecurestorage intenc

One of the following action can be selected:
    -n | --newsecurestorage <value>   Create new Secure Storage of type
                            int     Root File System with integrity
                            enc     Encrypted root file system
                            intenc  Encrypted root file system with integrity
    -h | --help             This Help
    -v | --version          The version of the $(basename $0)

The following PARAMETER must be set for new Secure Storage:
    -p | --flashpath <flash device>
    -s | --filesystem <path to root as tgz>
    -l | --flashlayout <value>    partion number for the rootfs partitions
                       2,4        rootfs partitions are 2 and 4 (old)
                       5,6        rootfs partitions are 5 and 6 (new)

The following PARAMETER can be set for new Secure Storage:
    -r | --rauc   (A/B system on the flash)
"

FLASH_PATH=""
FILE_SYSTEM=""
FLASH_LAYOUT[0]=2
FLASH_LAYOUT[1]=4
DORAUC=1

# Check, if keys exists
check_keysexist() {
	#keys in keyring
	retvalue=0
	if [ $(keyctl list @u | grep rootfs | wc -l) -gt 0 ]; then
		retvalue=1
	elif [ ! -z "$(ls -A -- "/mnt_secrets/secrets")" ]; then
		retvalue=2
	fi
	echo "$retvalue"
}

# Init integrity
# ${1} path to device
init_integrity() {
	modprobe dm-integrity
	integritysetup format ${1} --batch-mode --tag-size 32 --integrity sha256 --journal-integrity sha256
	integritysetup open ${1} --batch-mode --integrity sha256 --journal-integrity sha256 introotfs
}

# Close integrity device
init_integrityclose() {
	integritysetup close introotfs
}

# Init encryption
# ${1} path to device
init_enc() {
	modprobe dm-crypt
	if [ $(keyctl list @u | grep "encrypted: rootfs" | wc -l) -eq 1 ]; then
		dmsetup create encrootfs --table "0 $(blockdev --getsz ${1}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${1} 0"
	elif [ $(keyctl list @u | grep "logon: rootfs" | wc -l) -eq 1 ]; then
		dmsetup create encrootfs --table "0 $(blockdev --getsz ${1}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${1} 0"
	else
		echo "No Key for rootfs encryption"
		return 1
	fi
}

# Close encryption device
init_encclose() {
	cryptsetup remove encrootfs
}

# Format device and install rootfs
# ${1} root number for label name of partition
# ${2} path to device
# ${3} rootfs as tgz
install_files() {
	mkfs.ext4 -L root${1} -t ext4 ${2}
	mount ${2} /newroot
	tar xvfz ${3} -C /newroot/
	sync
	umount /newroot
}

#
# Command line options
#
ARGS=$(getopt -n $(basename $0) -o p:s:l:rn:vh -l flashpath:,filesystem:,flashlayout:,rauc,newsecurestorage:,version,help -- "$@")
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
	-l | --flashlayout)
		FLASH_LAYOUT[0]=$(echo ${2} | cut -d',' -f1);
		FLASH_LAYOUT[1]=$(echo ${2} | cut -d',' -f2);
		shift 2;;
	-r | --rauc) DORAUC=2; shift 1;;
	-n | --newsecurestorage)
		if [ -z "${FLASH_PATH}" ] || [ -z "${FILE_SYSTEM}" ]; then
			echo "Set flash path and filesystem first!"
			exit 4
		fi
		retvalue=$(check_keysexist)
		if [ ${retvalue} -eq 0 ]; then
			echo "Load or create a Secure Key Storage first!"
			exit 5
		fi
		j=0
		flashpart=2
		while [ $j -lt $DORAUC ]
		do
			case ${2} in
			int)
				echo "file system with integrity: ${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				init_integrity "${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				install_files $j "/dev/mapper/introotfs" ${FILE_SYSTEM}
				init_integrityclose
				;;
			enc)
				echo "encrypted file system: ${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				init_enc "${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				install_files $j "/dev/dm-0" ${FILE_SYSTEM}
				init_encclose
				;;
			intenc)
				echo "file system with integrity: ${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				init_integrity "${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				echo "encrypted file system with integrity: /dev/dm-1"
				init_enc "/dev/mapper/introotfs"
				install_files $i "/dev/dm-1" ${FILE_SYSTEM}
				init_encclose
				init_integrityclose
				;;
			*)
				echo "Unknown Parameter for Secure Storage"
				exit 3
			esac
			j=`expr $j + 1`
			flashpart=`expr $flashpart + 2`
		done
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
