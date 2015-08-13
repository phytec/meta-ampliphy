# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

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
    ${@bb.utils.contains("MACHINE_FEATURES", "touchscreen", "tslib-conf tslib-calibrate tslib-tests", "", d)} \
    fbtest \
    memedit \
    memtester \
    mtd-utils \
    mtd-utils-ubifs \
    mtd-utils-misc \
    iproute2 \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "can-utils", "", d)} \
    bumprts \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "pciutils", "", d)} \
"

# those packages depend on the specific layers
RDEPENDS_${PN}_append_ti33x = " phyedit"
