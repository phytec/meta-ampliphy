require partup.inc

SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "dbdb782dbd46a09be60f354e70611287399259a2"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.3.0+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
