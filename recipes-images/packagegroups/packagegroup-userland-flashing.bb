DESCRIPTION = "Userland software services to flash storage devices"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    bmap-tools \
    partup \
    xz \
    phytec-eeprom-flashtool \
"
