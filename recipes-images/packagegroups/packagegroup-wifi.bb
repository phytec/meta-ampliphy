DESCRIPTION = "Phytec wifi software"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# wpa_supplicant and wireless-tools are already install in packagegroup-base-wifi

RDEPENDS:${PN} = " \
    wpa-supplicant \
    iw \
    hostapd \
    laird-sterling-firmware \
    linux-firmware-wl18xx \
    linux-firmware-iwlwifi \
"

RDEPENDS:${PN}:remove:mx6ul-generic-bsp = "linux-firmware-iwlwifi"
