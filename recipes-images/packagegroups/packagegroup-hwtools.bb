DESCRIPTION = "Hardware development tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    usbutils \
    ethtool \
    i2c-tools \
    devmem2 \
    iw \
    bc \
    fbtest \
    libdrm-tests \
    memedit \
    memtester \
    e2fsprogs-mke2fs \
    dosfstools \
    e2fsprogs-tune2fs \
    e2fsprogs-resize2fs \
    parted \
    mmc-utils \
    flashbench \
    util-linux-blkdiscard \
    mtd-utils \
    mtd-utils-ubifs \
    mtd-utils-misc \
    nandflipbits \
    iproute2 \
    bumprts \
    serial-test \
    rs485test \
    libgpiod \
    phytool \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "can-utils", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "resistivetouch", "tslib-conf tslib-calibrate tslib-tests", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "pciutils", "", d)} \
    kmsxx \
    lmsensors-fancontrol \
"

# Those packages depend on a specific SoC architecture
RDEPENDS_${PN}_append_arm = " arm-memspeed"
RDEPENDS_${PN}_append_mx6 = " mmdc bbu"
RDEPENDS_${PN}_append_mx6ul = " mmdc bbu"
RDEPENDS_${PN}_append_rk3288 = " rkeeprom"
RDEPENDS_${PN}_append_ti33x = " phyedit bbu"
