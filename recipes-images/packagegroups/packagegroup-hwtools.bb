DESCRIPTION = "Hardware development tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
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
    nandflipbits-wrapper \
    iproute2 \
    bumprts \
    serial-test \
    serialcheck \
    rs485test \
    libgpiod \
    libgpiod-tools \
    phytool \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "can-utils can-utils-cantest libsocketcan", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "resistivetouch", "tslib-conf tslib-calibrate tslib-tests", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "pciutils", "", d)} \
    kmsxx \
    lmsensors-fancontrol \
    nfs-utils-client \
    dtc \
    rauc-flash-nand \
    stressapptest \
    spidev-test \
"

# Those packages depend on a specific SoC architecture
RDEPENDS:${PN}:append:arm = " arm-memspeed"
RDEPENDS:${PN}:append:mx6-generic-bsp = " mmdc bbu"
RDEPENDS:${PN}:append:mx6ul-generic-bsp = " mmdc bbu phycam-setup"
RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " phycam-setup"
RDEPENDS:${PN}:append:rk3288 = " rkeeprom"
RDEPENDS:${PN}:append:ti33x = " phyedit bbu"
