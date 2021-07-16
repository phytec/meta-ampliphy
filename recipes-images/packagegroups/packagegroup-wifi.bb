DESCRIPTION = "Phytec wifi software"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# wpa_supplicant and wireless-tools are already install in packagegroup-base-wifi

RDEPENDS_${PN} = " \
    wpa-supplicant \
    iw \
    hostapd \
    linux-firmware-bcm4339 \
    linux-firmware-bcm43430 \
"
