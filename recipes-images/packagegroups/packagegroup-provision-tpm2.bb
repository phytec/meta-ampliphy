DESCRIPTION = "Packagegroup for TPM2 provisioning"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    tpm2-tools \
"
