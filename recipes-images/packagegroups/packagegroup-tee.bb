DESCRIPTION = "OPTEE packages"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} += " \
    optee-client \
    optee-test \
    opensc \
    libp11 \
    pkcs11-provider \
"
