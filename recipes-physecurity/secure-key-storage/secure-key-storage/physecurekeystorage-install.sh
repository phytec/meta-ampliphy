#!/bin/sh

set -e
trap end EXIT
end() {
	if [ "$?" -ne 0 ]; then
		printf "\n[ERROR] Secure Key Storage install" 1>&2
		exit $?
	fi
}

version="v1.0"
usage="
PHYTEC Install Script ${version} for Secure Key Storage

Usage:  $(basename $0) [PARAMETER] [ACTION]

Example:
    $(basename $0) --newkeystorage trustedtpm
    $(basename $0) --deletekeystorage
    $(basename $0) --loadkeystorage

One of the following action can be selected:
    -n | --newkeystorage <value>  Create new Secure Key Storage
                            trustedcaam or securecaam (black blob NXP BSP)
                            trustedtee
                            trustedtpm
    -d | --deletekeystorage Erase the existing Secure Key Storage
    -l | --loadkeystorage   Load the existing Secure Key Storage
    -h | --help             This Help
    -v | --version          The version of $(basename $0)
"

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

# Parameter
# key type
init_keystore() {
	case ${1} in
	trustedtpm|trustedtee|trustedcaam)
		if [ $(expr match ${1} 'trustedtpm') -gt 0 ]; then
			echo "Init TPM"
			tpm2_clear
			tpm2_createprimary --hierarchy=o --key-algorithm=rsa --key-context=prim.ctx
			tpm2_evictcontrol --hierarchy=o --object-context=prim.ctx 0x81000001
		fi
		len=$(expr length ${1})
		trustlen=$(expr match ${1} 'trusted')
		echo "Create trusted key"
		pos=$(expr $trustlen + 1)
		lentype=$(expr $len - $trustlen)
		trustedtype=$(expr substr "${1}" ${pos} ${lentype})
		modprobe trusted source=${trustedtype}
		modprobe encrypted-keys
		echo "trustedsource=${trustedtype}" > /mnt_secrets/secrets/trusted_key.config
		if [ "${trustedtype}" = "tpm" ]; then
			trustedid=$(keyctl add trusted kmk "new 64 keyhandle=0x81000001" @u)
		else
			trustedid=$(keyctl add trusted kmk "new 64" @u)
		fi
		echo "Create encrypted key"
		encid=$(keyctl add encrypted rootfs "new trusted:kmk 64" @u)
		keyctl pipe ${trustedid} > /mnt_secrets/secrets/trusted_key.blob
		keyctl pipe ${encid} > /mnt_secrets/secrets/encrypted_key.blob
		;;
	securecaam)
		echo "Create NXP secure Key (black blob)"
		caam-keygen create tksecure_key ccm -s 32
		cat /mnt_secrets/secrets/tksecure_key | keyctl padd logon rootfs: @u
		;;
	*)
		echo "Not supported Key type"
	esac
}

load_keystore() {
	if test -f /mnt_secrets/secrets/trusted_key.config; then
		source /mnt_secrets/secrets/trusted_key.config
		modprobe -q  trusted source=${trustedsource}
	else
		modprobe -q  trusted
	fi
	modprobe -q  encrypted-keys
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
}

erase_keystore() {
	keyctl clear @u
	[ $(lsmod | grep encrypted_keys | wc -l) -ne 0 ] && rmmod encrypted-keys
	[ $(lsmod | grep trusted | wc -l) -ne 0 ] && rmmod trusted
	rm /mnt_secrets/secrets/*
}

#
# Command line options
#
ARGS=$(getopt -n $(basename $0) -o n:dlvh -l newkeystorage:,deletekeystorage,loadkeystorage,version,help -- "$@")
VALID_ARGS=$?
if [ "$VALID_ARGS" != "0" ]; then
	echo "${usage}"
	exit 2
fi

eval set -- "$ARGS"
while :
do
	case ${1} in
	-n | --newkeystorage)
		echo "Checking, if a Secure Key storage exist"
		retvalue=$(check_keysexist)
		if [ $retvalue -ne 0 ]; then
			echo "Delete existing Secure Key Storage first!"
			exit 1
		fi
		echo "Creating new Secure Key Storage (${2})"
		init_keystore ${2}
		exit 0
		;;
	-d | --deletekeystorage)
		echo "Deleting existing Secure Key Storage!"
		erase_keystore
		exit 0
		;;
	-l | --loadkeystorage)
		echo "Loading existing Secure Key Storage"
		load_keystore
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
		echo "Unknown Action"
		echo "${usage}"
		exit 2
	esac
done