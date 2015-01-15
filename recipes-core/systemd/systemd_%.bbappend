FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd"

SRC_URI_append = " \
    file://eth0.network \
    file://eth1.network \
"

do_install_append () {
        install -m 0644 ${WORKDIR}/*.network ${D}${sysconfdir}/systemd/network
}
