DESCRIPTION = "Hardware development diagnostic tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    usbutils \
    ethtool \
    i2c-tools \
    mmc-utils \
    devmem2 \
    iw \
    bc \
    fbtest \
    libdrm-tests \
    memtester \
    flashbench \
    iproute2 \
    bumprts \
    linux-serial-test \
    serialcheck \
    rs485conf \
    rs485test \
    libgpiod \
    libgpiod-tools \
    phytool \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "can-utils can-utils-cantest libsocketcan", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "resistivetouch", "tslib-conf tslib-calibrate tslib-tests", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "pciutils", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "linux-firmware-rtl-nic", "", d)} \
    kmsgrab \
    nfs-utils-client \
    dtc \
    stressapptest \
    spidev-test \
    rng-tools \
    tcpdump \
"

RDEPENDS:${PN}:append:arm = " arm-memspeed"
RDEPENDS:${PN}:append:mx6-generic-bsp = " mmdc phycam-setup"
RDEPENDS:${PN}:append:mx6ul-generic-bsp = " mmdc"
RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " phycam-setup"
RDEPENDS:${PN}:append:rk3288 = " rkeeprom"

RDEPENDS:${PN}:append:j721s2 = " lmsensors-fancontrol"
RDEPENDS:${PN}:append:mx8m-generic-bsp = " lmsensors-fancontrol"
