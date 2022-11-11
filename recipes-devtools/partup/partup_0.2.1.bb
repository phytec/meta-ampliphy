require partup.inc

SRC_URI = "https://github.com/phytec/partup/releases/download/v${PV}/${BPN}-${PV}.tar.gz"
SRC_URI[sha256sum] = "325424bcee396a2dd594163b22510aca289cda2181719b4b84e3818715269759"

UPSTREAM_CHECK_URI = "https://github.com/phytec/partup/releases"
