require partup.inc

SRC_URI = "https://github.com/phytec/partup/releases/download/v${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "d98f128312adcca2ee873d67be840fb471bf00e14843b979708000a4a6d42851"

UPSTREAM_CHECK_URI = "https://github.com/phytec/partup/releases"
