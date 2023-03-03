require partup.inc

SRC_URI = "https://github.com/phytec/partup/releases/download/v${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "49e28662cabba20803e248b0bfd543cca7e52b6f8e198622ce8e1b8301c934dd"

UPSTREAM_CHECK_URI = "https://github.com/phytec/partup/releases"
