DESCRIPTION =  "Packagegroup  Secure Key Storage for openssl and \
                TPM2 userspace and utilities."
LICENSE = "MIT"

inherit packagegroup

SUMMARY:packagegroup-openssl-tpm2 = "openssl with TPM 2.0 support"

RDEPENDS:${PN} = " \
    tpm2-tss \
    libtss2 \
    tpm2-tss-engine \
    openssl-bin \
"
