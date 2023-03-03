require partup.inc

SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "d7ca0dcbbd91ddb367994e519707d87827600173"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.3.1+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
