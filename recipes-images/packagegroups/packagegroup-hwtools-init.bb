DESCRIPTION = "Hardware tools for Phytec board initialisation"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    e2fsprogs-mke2fs \
    dosfstools \
    e2fsprogs-tune2fs \
    e2fsprogs-resize2fs \
    parted \
    mmc-utils \
    util-linux-blkdiscard \
    mtd-utils \
    mtd-utils-ubifs \
    mtd-utils-misc \
    nandflipbits-wrapper \
    iproute2 \
    nfs-utils-client \
    rauc-flash-nand \
"

RDEPENDS:${PN}:append:mx6-generic-bsp = " bbu"
RDEPENDS:${PN}:append:mx6ul-generic-bsp = " bbu phycam-setup"
RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " phycam-setup"
RDEPENDS:${PN}:append:mx8mm-nxp-bsp = " phycam-setup"
RDEPENDS:${PN}:append:rk3288 = " rkeeprom"
RDEPENDS:${PN}:append:ti33x = " bbu"
