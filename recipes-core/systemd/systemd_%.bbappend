
PACKAGECONFIG = "xz resolved networkd"

RRECOMMENDS_${PN}_remove = "systemd-compat-units"
RDEPENDS_${PN} += "systemd-machine-units"
