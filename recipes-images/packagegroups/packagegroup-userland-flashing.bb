DESCRIPTION = "Userland software services to flash storage devices"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    bmap-tools \
    partup \
    xz \
"
