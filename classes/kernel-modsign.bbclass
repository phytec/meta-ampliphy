# Partially based on the class in meta-security

# Private key and cert for modules signing
MODSIGN_KEY ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"

DEPENDS_append_secureboot = " phytec-dev-ca-native"
do_patch_secureboot[depends] += "phytec-dev-ca-native:do_install"

do_configure_prepend() {
	if [ -f "${MODSIGN_KEY}" ]; then
		shasum=$(sha256sum "${MODSIGN_KEY}" | cut -d' ' -f1)
		if [ "$shasum" = "f18d3d04bcbdbb8fcbb992bb9a1e65a4b4683d646ef6b50bca26f74fd06e5e7d" ]; then
			bbwarn "!! CRITICAL SECURITY WARNING: You're using Phytec's Development Keyring for signing of kernel modules. Please create your own!!"
		fi
		cp "${MODSIGN_KEY}" "${B}/kernel_modsign_key.pem"
        else
		bberror "Kernel modsign key/cert ${MODSIGN_KEY} not found."
        fi
}

do_shared_workdir_append() {
	cp kernel_modsign_key.pem $kerneldir/
}
