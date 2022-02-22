DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    keyutils \
    kernel-module-trusted \
    kernel-module-encrypted-keys \
"

RDEPENDS:${PN}:append:mx8 = " keyctl-caam"
