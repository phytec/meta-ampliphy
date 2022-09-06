require partup.inc

SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "5f4033816d02f5914358a376ce6ab72dab334a44"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.2.0+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
