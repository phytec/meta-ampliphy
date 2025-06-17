FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

# Fix IP Address of newly found interfaces to 192.168.3.11

SRC_URI += " \
             file://phytec.config \
"

do_install:append () {
    install -D -m 0644 ${UNPACKDIR}/phytec.config ${D}/${localstatedir}/lib/connman/phytec.config
}
