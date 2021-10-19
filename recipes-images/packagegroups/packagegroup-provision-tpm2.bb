DESCRIPTION = "Packagegroup for TPM2 provisioning"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    tpm2-tools \
    tpm2-tss \
    libtss2 \
    libtss2-tcti-device \
"
