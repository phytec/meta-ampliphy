# Copyright (C) 2015 Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Phytec wifi software"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# wpa_supplicant and wireless-tools are already install in packagegroup-base-wifi

RDEPENDS_${PN} = " \
    wpa-supplicant \
    iw \
    hostapd \
    linux-firmware-wl12xx \
    wl12xx-calibrator \
"
