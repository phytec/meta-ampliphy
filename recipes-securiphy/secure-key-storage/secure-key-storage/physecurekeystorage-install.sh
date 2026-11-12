#!/bin/sh

set -e
trap end EXIT
end() {
	ret=$?
	if [ $ret -ne 0 ]; then
		printf "\n[ERROR] Secure Key Storage install\n" 1>&2
		exit $ret
	fi
}

version="v1.7"
CONFIG_DEV=@CONFIG_DEV@
CONFIG_MOUNTPATH=@CONFIG_MOUNTPATH@
ENCRYPTED_KEY_LABEL=@ENCRYPTED_KEY_LABEL@
TRUSTED_KEY_LABEL=@TRUSTED_KEY_LABEL@
TRUSTED_TYPE_LABEL=@TRUSTED_TYPE_LABEL@
TOKEN_NAME=@OPTEE_TRUSTED_TOKEN_NAME@
SLOT=@OPTEE_TRUSTED_SLOT@
SO_PIN_LABEL=@OPTEE_TRUSTED_SO_PIN_LABEL@
USER_PIN_LABEL=@OPTEE_TRUSTED_USER_PIN_LABEL@

TPM_FAPICONFIG="/etc/tpm2-tss/fapi-config.json"
SAVE_IN_TEE=0
OPTEE_LIB="/usr/lib/libckteec.so.0"

usage="
PHYTEC Install Script ${version} for Secure Key Storage

Usage:  $(basename $0) [PARAMETER] [ACTION]

Example:
    $(basename $0) --newkeystorage trustedtpm
    $(basename $0) --newkeystorage trustedtpm --save-in-tee
    $(basename $0) --deletekeystorage
    $(basename $0) --deletekeystorage --save-in-tee
    $(basename $0) --loadkeystorage
    $(basename $0) --pkcs11testkey /usr/lib/libckteec.so.0

One of the following action can be selected:
    -n | --newkeystorage <value>  Create new Secure Key Storage
                            trustedcaam (only NXP controller)
                            trustedtee
                            trustedtpm
                            securecaam (black blob only NXP Vendor BSP)
    -d | --deletekeystorage Clear the existing keyring and remove the secrets files
    -l | --loadkeystorage   Load the existing Secure Key Storage
    -p | --pkcs11testkey <value>  Create an ECC testkey with user pin 1234
                            /usr/lib/libckteec.so.0
                            /usr/lib/pkcs11/libtpm2_pkcs11.so
    -s | --save-in-tee      Save or delete the metadata of the encrypted key in OP-TEE
							By deletekeystorage, all the metadata in OP-TEE will also be removed
    -h | --help             This Help
    -v | --version          The version of $(basename $0)
"

optee_initialize_token() {
	if [ $SLOT -lt 0 ] || [ $SLOT -gt 2 ]; then
		echo "Slot number out of range(0-2): $SLOT"
		exit 1
	fi
	so_pin=$(openssl rand -hex 64)
	pin=$(openssl rand -hex 64)
	# Initialize PKCS#11 token
	pkcs11-tool --module ${OPTEE_LIB} --init-token --label ${TOKEN_NAME} --so-pin $so_pin --slot $SLOT
	pkcs11-tool --module ${OPTEE_LIB} --label ${TOKEN_NAME} --login --so-pin $so_pin --init-pin --pin $pin --slot $SLOT

	# Write the SO-PIN and user PIN to the token
	optee_write_obj "$so_pin" "${SO_PIN_LABEL}"
	optee_write_obj "$pin" "${USER_PIN_LABEL}"
}

# Parameter
# $1: obj to write to the token
# $2: obj label in the token
optee_write_obj() {
	# write object to temporary file
	tpm_file=$(mktemp)
	echo "${1}" > "${tpm_file}"
	# Write SO-PIN and user PIN to the token
	pkcs11-tool --module ${OPTEE_LIB} --token-label ${TOKEN_NAME} \
	--write-object "${tpm_file}" --type data \
	--label "${2}" \
	--slot $SLOT > /dev/null 2>&1
}

# Parameter
# $1: obj to read from the token
optee_read_obj() {
	# Create temporary file for reading the object
	tmp_file=$(mktemp)
	# read object from the token to temporary file
	pkcs11-tool --module ${OPTEE_LIB} --token-label ${TOKEN_NAME} \
	--read-object --type data \
	--label "${1}" \
	--slot $SLOT \
	--output-file "${tmp_file}" > /dev/null 2>&1 || echo ""

	cat "${tmp_file}"
}

check_keysexist() {
	#keys in keyring
	retvalue=0
	if [ $(keyctl list @u | grep rootfs | wc -l) -gt 0 ]; then
		retvalue=1
	elif [ ! -z "$(ls -A -- "${CONFIG_MOUNTPATH}/secrets")" ]; then
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
			resp="null"
			[ -f ${TPM_FAPICONFIG} ] && resp=$(jq -c -r '.ek_cert_less' ${TPM_FAPICONFIG})
			if [ "${resp}" != "yes" ] && ! nslookup phytec.de &> /dev/null]; then
				echo "An internet connection for checking the endorsement certificate from the TPM is necessary!"
				exit 5
			else
				echo "Init TPM"
				modprobe -q tpm_tis_spi
				tpm2_clear
				tss2_provision
			fi
		fi
		len=$(expr length ${1})
		trustlen=$(expr match ${1} 'trusted')
		echo "Create trusted key"
		pos=$(expr $trustlen + 1)
		lentype=$(expr $len - $trustlen)
		trustedtype=$(expr substr "${1}" ${pos} ${lentype})
		source_config="trustedsource=${trustedtype}"
		modprobe trusted source=${trustedtype}
		modprobe encrypted-keys
		if [ "${trustedtype}" = "tpm" ]; then
			trustedid=$(keyctl add trusted kmk "new 64 keyhandle=0x81000001" @u)
		else
			trustedid=$(keyctl add trusted kmk "new 64" @u)
		fi
		echo "Create encrypted key"
		encid=$(keyctl add encrypted rootfs "new trusted:kmk 64" @u)
		# Write to files or optee
		if [ $SAVE_IN_TEE -eq 1 ]; then
			echo "Save metadata in OP-TEE for SoC binding"
			optee_initialize_token
			optee_write_obj "${source_config}" "${TRUSTED_TYPE_LABEL}"
			optee_write_obj "$(keyctl pipe ${trustedid})" "${TRUSTED_KEY_LABEL}"
			optee_write_obj "$(keyctl pipe ${encid})" "${ENCRYPTED_KEY_LABEL}"
		else
			echo "${source_config}" > ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_TYPE_LABEL}
			keyctl pipe ${trustedid} > ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_KEY_LABEL}
			keyctl pipe ${encid} > ${CONFIG_MOUNTPATH}/secrets/${ENCRYPTED_KEY_LABEL}
		fi
		;;
	securecaam)
		echo "Create NXP secure Key (black blob)"
		caam-keygen create tksecure_key ccm -s 32
		cat ${CONFIG_MOUNTPATH}/secrets/tksecure_key | keyctl padd logon rootfs: @u
		;;
	*)
		echo "Not supported Key type"
		exit 1
	esac
}

load_keystore() {
	ret=""
	if [ -f ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb ]; then
		caam-keygen import ${CONFIG_MOUNTPATH}/secrets/tksecure_key.bb importkey
		cat ${CONFIG_MOUNTPATH}/secrets/importkey | keyctl padd logon rootfs: @u
	else
		if [ -f ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_TYPE_LABEL} ]; then
			ret=$(cat ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_TYPE_LABEL})
		else
			ret=$(optee_read_obj "${TRUSTED_TYPE_LABEL}")
			[ -n "$ret" ] && SAVE_IN_TEE=1
		fi
		if [ -n "$ret" ]; then
			trustedsource=$(expr "$ret" : '^trustedsource=\(tpm\|tee\|caam\)$')
			if [ $(expr match ${trustedsource} 'tpm') -gt 0 ]; then
				modprobe -q tpm_tis_spi
			fi
			modprobe -q  trusted source=${trustedsource}
		fi
		modprobe -q  encrypted-keys
		if [ $SAVE_IN_TEE -eq 0 ] && \
			[ -f ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_KEY_LABEL} ] && \
			[ -f ${CONFIG_MOUNTPATH}/secrets/${ENCRYPTED_KEY_LABEL} ]; then
			keyctl add trusted kmk  "load `cat ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_KEY_LABEL}`" @u
			keyctl add encrypted rootfs  "load `cat ${CONFIG_MOUNTPATH}/secrets/${ENCRYPTED_KEY_LABEL}`" @u
		elif [ $SAVE_IN_TEE -eq 1 ] && \
			[ ! -f ${CONFIG_MOUNTPATH}/secrets/${TRUSTED_KEY_LABEL} ] && \
			[ ! -f ${CONFIG_MOUNTPATH}/secrets/${ENCRYPTED_KEY_LABEL} ]; then
			keyctl add trusted kmk  "load $(optee_read_obj ${TRUSTED_KEY_LABEL})" @u
			keyctl add encrypted rootfs  "load $(optee_read_obj ${ENCRYPTED_KEY_LABEL})" @u
		else
			echo "Error: Cannot load keys from TEE or filesystem"
		fi
	fi
}

erase_keystore() {
	keyctl clear @u
	[ $(lsmod | grep dm_crypt | wc -l) -ne 0 ] && rmmod dm-crypt
	[ $(lsmod | grep encrypted_keys | wc -l) -ne 0 ] && rmmod encrypted-keys
	[ $(lsmod | grep trusted | wc -l) -ne 0 ] && rmmod trusted
	rm -rf ${CONFIG_MOUNTPATH}/secrets/*
	if [ $SAVE_IN_TEE -eq 1 ]; then
		rm -rf ${CONFIG_MOUNTPATH}/optee/*
		echo "Reboot to complete the deletion"
	fi
}

check_storage() {
	# Check directory and mount
	if [ ! -d ${CONFIG_MOUNTPATH} ]; then
		mkdir -p ${CONFIG_MOUNTPATH}
	fi
	mountpoint -q ${CONFIG_MOUNTPATH} || mount ${CONFIG_DEV} ${CONFIG_MOUNTPATH}
	if [ $(mount | grep ${CONFIG_MOUNTPATH} | wc -l) -eq 0 ]; then
		echo "Error: No Partition is mounted to ${CONFIG_MOUNTPATH}"
		echo "Please install sdcard image to your emmc at first"
		exit 4
	fi

	if [ ! -d ${CONFIG_MOUNTPATH}/secrets ]; then
		mkdir ${CONFIG_MOUNTPATH}/secrets
	fi

	if [ ! -d ${CONFIG_MOUNTPATH}/tpm2/pkcs11 ]; then
		mkdir -p ${CONFIG_MOUNTPATH}/tpm2/pkcs11 --mode=755
	fi
}

#
# Command line options
#
ARGS=$(getopt -n "$(basename $0)" -o n:sdlp:vh -l newkeystorage:,save-in-tee,deletekeystorage,loadkeystorage,pkcs11testkey:,version,help -- "$@")
VALID_ARGS=$?
if [ "$VALID_ARGS" != "0" ]; then
	echo "${usage}"
	exit 2
fi

new_key=0
delete_key=0
type=""

eval set -- "$ARGS"
while :
do
	case ${1} in
	-n | --newkeystorage)
		new_key=1
		type=${2}
		shift 2
		;;
	-s | --save-in-tee)
		SAVE_IN_TEE=1
		shift
		;;
	-d | --deletekeystorage)
		delete_key=1
		shift
		;;
	-l | --loadkeystorage)
		echo "Loading existing Secure Key Storage"
		check_storage
		load_keystore
		exit 0
		;;
	-p | --pkcs11testkey)
		if [ ! -f "${2}" ]; then
			echo "Error: PKCS#11 module ${2} not found!"
			exit 1
		fi
		p11="pkcs11-tool --module ${2}"
		# init test token
		$p11 --init-token --label=test --so-pin=1234
		# set user pin
		$p11 --label="test" --init-pin --so-pin 1234 --pin 1234
		# create test keypair
		$p11 --label="test-keypair" --login --pin=1234 --keypairgen --usage-sign --key-type EC:prime256v1 -d 1

		echo "Delete the generated metadata, depending on the PKCS#11 module's configuration"
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
	--)
		shift
		break
		;;
	*)
		echo "Unknown Action"
		echo "${usage}"
		exit 2
	esac
done

if [ $new_key -eq 1 ]; then
	echo "Checking, if a Secure Key storage exist"
	check_storage
	retvalue=$(check_keysexist)
	if [ $retvalue -ne 0 ]; then
		echo "Delete existing Secure Key Storage first!"
		exit 1
	fi
	echo "Creating new Secure Key Storage ${type}"

	init_keystore "${type}"
	exit 0
elif [ $delete_key -eq 1 ]; then
	echo "Deleting existing Secure Key Storage!"
	check_storage
	erase_keystore
	exit 0
fi
