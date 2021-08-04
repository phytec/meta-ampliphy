DESCRIPTION = "Update tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} += " \
    rauc \
    rauc-hawkbit-updater \
    rauc-update-usb \
"
