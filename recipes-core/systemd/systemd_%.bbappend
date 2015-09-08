FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd"

RRECOMMENDS_${PN}_remove = "systemd-compat-units"
RDEPENDS_${PN} += "systemd-machine-units"

SRC_URI_append = " \
    file://0001-networkd-fix-IFF_UP-when-ipv6-support-is-disabled.patch \
"
