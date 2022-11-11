require partup.inc

SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "dd2b5ea768aa76bf940a3fcd7a5a0b1153e39bcf"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.2.1+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
