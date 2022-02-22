DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    keyutils \
    kernel-module-trusted \
    kernel-module-encrypted-keys \
"

RDEPENDS_${PN}_append_mx8 = " keyctl-caam"
