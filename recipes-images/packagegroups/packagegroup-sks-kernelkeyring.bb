DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    keyutils \
"

RDEPENDS:${PN}:append:mx8 = " keyctl-caam"
