# Partially based on the class in meta-security

# Private key and cert for modules signing
MODSIGN_KEY ?= "${CERT_PATH}/kernel_modsign/kernel_modsign.pem"

do_configure_prepend() {
	if [ -f "${MODSIGN_KEY}" ]; then
		cp "${MODSIGN_KEY}" "${B}/kernel_modsign_key.pem"
        else
		bberror "Kernel modsign key/cert ${MODSIGN_KEY} not found."
        fi
}

do_shared_workdir_append() {
	cp kernel_modsign_key.pem $kerneldir/
}
