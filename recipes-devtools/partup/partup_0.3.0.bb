require partup.inc

SRC_URI = "https://github.com/phytec/partup/releases/download/v${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "cf5f087dc863eb53e1a1e20f294719bbc7e1cf9815739922ede32a9711e7c8d6"

UPSTREAM_CHECK_URI = "https://github.com/phytec/partup/releases"
