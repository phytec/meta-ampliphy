FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd"

SRC_URI_append = " \
    file://eth0.network \
    file://eth1.network \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can0.service", "", d)} \
"

do_install_append () {
    for file in ${WORKDIR}/*.network
    do
        install -d ${D}${systemd_unitdir}/network/
        install -m 0644 $file ${D}${systemd_unitdir}/network/
    done
    for file in ${WORKDIR}/*.service
    do
        install -d ${D}${systemd_unitdir}/system/
        install -m 0644 $file ${D}${systemd_unitdir}/system/
    done
}
