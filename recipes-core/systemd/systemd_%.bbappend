FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd"

SRC_URI_append = " \
    file://eth0.network \
    file://eth1.network \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can0.service", "", d)} \
"

do_install_append () {
        install -d ${D}${systemd_unitdir}/network/
        install -m 0644 ${WORKDIR}/*.network ${D}${systemd_unitdir}/network/
        install -d ${D}${systemd_unitdir}/system/
        install -m 0644 ${WORKDIR}/*.service ${D}${systemd_unitdir}/system/
}
