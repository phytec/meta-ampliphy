DESCRIPTION = "Packagegroup for openssl and TPM2 userspace and utilities."
LICENSE = "MIT"

inherit packagegroup

SUMMARY_packagegroup-openssl-tpm2 = "openssl with TPM 2.0 support"

RDEPENDS_${PN} = " \
    tpm2-tss \
    libtss2 \
    libtss2-mu \
    libtss2-tcti-device \
    libtss2-tcti-mssim \
    tpm2-tss-engine \
    openssl-bin \
"
