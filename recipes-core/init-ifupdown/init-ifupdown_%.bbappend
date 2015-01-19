FILESEXTRAPATHS_prepend := "${THISDIR}:"

SRC_URI += "${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can-pre-up", "", d)}"

do_install_append () {
    if [ -e ${WORKDIR}/can-pre-up ] ; then
        install -m 0755 ${WORKDIR}/can-pre-up ${D}${sysconfdir}/network/can-pre-up
    fi
}
