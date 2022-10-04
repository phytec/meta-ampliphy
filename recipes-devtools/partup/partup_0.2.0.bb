require partup.inc

SRC_URI = "https://github.com/phytec/partup/releases/download/v${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "db25a68f5cca5adaf93c754d5777b4c890244971fba77788f68f2a92b906d18b"

UPSTREAM_CHECK_URI = "https://github.com/phytec/partup/releases"
