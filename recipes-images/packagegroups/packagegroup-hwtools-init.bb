DESCRIPTION = "Hardware tools for Phytec board initialisation"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
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
    nandflipbits \
    iproute2 \
    nfs-utils-client \
    rauc-flash-nand \
"

RDEPENDS_${PN}_append_mx6 = " bbu"
RDEPENDS_${PN}_append_mx6ul = " bbu"
RDEPENDS_${PN}_append_mx8mp = " phycam-setup"
RDEPENDS_${PN}_append_rk3288 = " rkeeprom"
RDEPENDS_${PN}_append_ti33x = " bbu"
