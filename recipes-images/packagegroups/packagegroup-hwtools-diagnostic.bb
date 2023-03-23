DESCRIPTION = "Hardware development diagnostic tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    usbutils \
    ethtool \
    i2c-tools \
    mmc-utils \
    devmem2 \
    iw \
    bc \
    fbtest \
    libdrm-tests \
    memedit \
    memtester \
    flashbench \
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
    kmsgrab \
    lmsensors-fancontrol \
    nfs-utils-client \
    dtc \
    stressapptest \
    spidev-test \
"

RDEPENDS_${PN}_append_arm = " arm-memspeed"
RDEPENDS_${PN}_append_k3 = " k3conf"
RDEPENDS_${PN}_append_mx6 = " mmdc"
RDEPENDS_${PN}_append_mx6ul = " mmdc"
RDEPENDS_${PN}_append_mx8mp = " phycam-setup"
RDEPENDS_${PN}_append_rk3288 = " rkeeprom"
RDEPENDS_${PN}_append_ti33x = " phyedit"
