DESCRIPTION =  "Packagegroup  Secure Key Storage for openssl and \
                TPM2 userspace and utilities."
LICENSE = "MIT"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

SUMMARY:packagegroup-openssl-tpm2 = "openssl with TPM 2.0 support"

RDEPENDS:${PN} = " \
    tpm2-tss \
    libtss2 \
    libtss2-mu \
    libtss2-tcti-device \
    libtss2-tcti-mssim \
    tpm2-tss-engine \
    openssl-bin \
"
