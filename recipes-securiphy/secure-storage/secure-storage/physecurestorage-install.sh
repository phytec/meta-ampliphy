#!/bin/sh

set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[ERROR] Secure Storage install" 1>&2
		exit $?
	fi
}

version="v1.5"
FLASH_PATH=@FLASH_PATH@
LABEL_NAME="root"

usage="
PHYTEC Install Script ${version} for Secure Storage

Usage:  $(basename $0) [PARAMETER] [ACTION]

Example:
    $(basename $0) --flashpath ${FLASH_PATH}
    --filesystem /media/phytec-security-image.ext4
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
    -p | --flashpath <flash device> = ${FLASH_PATH}
    -s | --filesystem <path to root as tgz or ext4>
    -l | --flashlayout <value>    partion number for the rootfs partitions
                       5,6        rootfs partitions are 5 and 6
    -L | --labelname <value>      label name for the partition
"

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
	fi
	echo "$retvalue"
}

# Init integrity
# ${1} path to device
init_integrity() {
	modprobe dm-integrity
	integritysetup format ${1} --batch-mode --tag-size 32 --integrity sha256 --journal-integrity sha256 --no-wipe
	integritysetup open ${1} --batch-mode --integrity sha256 --journal-integrity sha256 --integrity-recalculate --journal-commit-time=5000  introotfs
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
		dmsetup create encrootfs --table "0 $(blockdev --getsz ${1}) crypt aes-xts-plain64 :64:encrypted:rootfs 0 ${1} 0 2 no_read_workqueue no_write_workqueue"
	elif [ $(keyctl list @u | grep "logon: rootfs" | wc -l) -eq 1 ]; then
		dmsetup create encrootfs --table "0 $(blockdev --getsz ${1}) crypt capi:tk(cbc(aes))-plain :64:logon:rootfs: 0 ${1} 0"
	else
		echo "No Key for rootfs encryption"
		return 1
	fi
}

# Close encryption device
init_encclose() {
	while [ $(cryptsetup status encrootfs | grep "is in use" | wc -l) -ne 0 ]; do
		sync -f
	done
	cryptsetup close encrootfs
}

# Format device and install rootfs
# ${1} label name of partition
# ${2} path to device
# ${3} rootfs as tgz or ext4
install_files() {
	filename=$(basename "${3}")
	if [ "${filename##*.}" = "ext4" ]; then
		dd if=${3} of=${2} bs=100M conv=fsync
		resize2fs ${2}
	else
		mkfs.ext4 -L ${1} -t ext4 ${2}
		mount ${2} /newroot
		if [ "${filename##*.}" = "tgz" ] || [ "${filename##*.tar.}" = "gz" ]; then
			tar xfz ${3} -C /newroot/ --warning=no-timestamp
		elif [ "${filename##*.tar.}" = "xz" ]; then
			tar xf ${3} -C /newroot/
		else
			echo "Not supported file system"
			return 1
		fi
		sync
		umount /newroot
	fi
}

mkdir -p /newroot

#
# Command line options
#
ARGS=$(getopt -n $(basename $0) -o p:s:l:n:L:vh -l flashpath:,filesystem:,flashlayout:,newsecurestorage:,labelname:,version,help -- "$@")
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
		if [ ${FLASH_LAYOUT[0]} -ne ${FLASH_LAYOUT[1]} ]; then
			DORAUC=2
		fi
		shift 2;;
	-L | --labelname) LABEL_NAME=${2} shift 2;;
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
				install_files "${LABEL_NAME}${j}" "/dev/mapper/introotfs" ${FILE_SYSTEM}
				init_integrityclose
				;;
			enc)
				echo "encrypted file system: ${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				init_enc "${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				install_files "${LABEL_NAME}${j}" "/dev/dm-0" ${FILE_SYSTEM}
				init_encclose
				;;
			intenc)
				echo "file system with integrity: ${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				init_integrity "${FLASH_PATH}p${FLASH_LAYOUT[j]}"
				echo "encrypted file system with integrity: /dev/dm-1"
				init_enc "/dev/mapper/introotfs"
				install_files "${LABEL_NAME}${j}" "/dev/dm-1" ${FILE_SYSTEM}
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
