# Partially based on the class in meta-security

# Private key and cert for modules signing. MODSIGN_KEY can be a PKCS11 URI too
MODSIGN_KEY ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"
MODSIGN_CERT ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"

DEPENDS:append:kernelmodsign = " phytec-dev-ca-native libp11-native"
do_patch:kernelmodsign[depends] += "phytec-dev-ca-native:do_install"


check_dev_key() {
	if [ -f "${1}" ]; then
		shasum=$(sha256sum "${1}" | cut -d' ' -f1)
		if [ "$shasum" = "f18d3d04bcbdbb8fcbb992bb9a1e65a4b4683d646ef6b50bca26f74fd06e5e7d" ]; then
			bbwarn "!! CRITICAL SECURITY WARNING: You're using Phytec's Development Keyring for signing of kernel modules. Please create your own!!"
		fi
	fi
}

do_configure:prepend() {
	if [ ! -f "${MODSIGN_CERT}" ]; then
		bberror "Kernel modsign cert ${MODSIGN_CERT} not found."
	fi
	if [ ! -f "${MODSIGN_KEY}" ]; then
		echo "${MODSIGN_KEY}" | grep -q "^pkcs11:" || bberror "Kernel modsign key ${MODSIGN_KEY} not found and not a 'pkcs11:' URI"
	fi

	check_dev_key "${MODSIGN_CERT}"
	check_dev_key "${MODSIGN_KEY}"
}

do_configure:append() {
	kconfig_set MODULE_SIG_KEY "\"${MODSIGN_KEY}\""
	kconfig_set SYSTEM_TRUSTED_KEYS "\"${MODSIGN_CERT}\""
}

set_pkcs11_env_vars() {
	engines_dir=`basename $( openssl version -e | sed -e 's/.*"\(.*\)".*/\1/g')`
	export OPENSSL_ENGINES="${WORKDIR}/recipe-sysroot-native/usr/lib/${engines_dir}"
	export PKCS11_MODULE_PATH="${PKCS11_MODULE_PATH}"

}

do_compile:prepend() {
	set_pkcs11_env_vars
}

do_install:prepend() {
	set_pkcs11_env_vars
}
