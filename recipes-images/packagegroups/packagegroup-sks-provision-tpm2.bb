DESCRIPTION = "Packagegroup Secure Key Storage for TPM2 provisioning"
LICENSE = "MIT"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    tpm2-tools \
    tpm2-tss \
    libtss2 \
    libtss2-tcti-device \
"
