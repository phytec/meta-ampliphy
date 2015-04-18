FILESEXTRAPATHS_prepend := "${THISDIR}:"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SRC_URI += "${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can-pre-up", "", d)}"
SRC_URI[vardeps] += "MACHINE_FEATURES"

do_install_append () {
    if [ -e ${WORKDIR}/can-pre-up ] ; then
        install -m 0755 ${WORKDIR}/can-pre-up ${D}${sysconfdir}/network/can-pre-up
    fi
}
