DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    keyutils \
"

RDEPENDS_${PN}_append_mx8 = " keyctl-caam"
