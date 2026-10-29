inherit kconfig-set

# Partially based on the class in meta-security

# Private key and cert for modules signing. MODSIGN_KEY can be a PKCS11 URI too
MODSIGN_KEY ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"
MODSIGN_CERT ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"

DEPENDS:append:kernelmodsign = " phytec-dev-ca-native"
do_patch[depends] += "${@bb.utils.contains("DISTRO_FEATURES", "kernelmodsign", "phytec-dev-ca-native:do_install", "", d)}"


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
		bberror "Kernel modsign key ${MODSIGN_KEY} not found."
	fi

	check_dev_key "${MODSIGN_CERT}"
	check_dev_key "${MODSIGN_KEY}"
}

do_configure:append() {
	kconfig_set MODULE_SIG_KEY "\"${MODSIGN_KEY}\""
	kconfig_set SYSTEM_TRUSTED_KEYS "\"${MODSIGN_CERT}\""
}
PARALLEL_MAKE:task-install = "-j 1"
