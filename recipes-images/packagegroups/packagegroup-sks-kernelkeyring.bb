DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit features_check packagegroup

REQUIRED_DISTRO_FEATURES = "secureboot"

RDEPENDS:${PN} = " \
    keyutils \
    kernel-module-trusted \
    kernel-module-encrypted-keys \
"

RDEPENDS:${PN}:append:mx8-nxp-bsp = " keyctl-caam"
