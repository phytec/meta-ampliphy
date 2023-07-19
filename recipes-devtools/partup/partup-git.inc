SRC_URI = "git://github.com/phytec/partup;branch=main;protocol=https"
SRCREV = "d570df686d2aba1654eadc928673dff78e0ab83f"

UPSTREAM_CHECK_COMMITS = "1"

PV = "0.4.0+git${SRCPV}"
S = "${WORKDIR}/git"

DEFAULT_PREFERENCE = "-1"
