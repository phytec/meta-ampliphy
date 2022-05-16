require partup.inc

SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "cf65c4efafe0176b554e60f796e0bcc8e7db679a"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.1.0+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
