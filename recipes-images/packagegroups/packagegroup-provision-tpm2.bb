DESCRIPTION = "Packagegroup for TPM2 provisioning"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    tpm2-tools \
"
