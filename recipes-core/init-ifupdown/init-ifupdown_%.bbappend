FILESEXTRAPATHS_prepend := "${THISDIR}:"

SRC_URI_ti33x += "file://can-pre-up"

do_install_append () {
    if [ -e ${WORKDIR}/can-pre-up ] ; then
        install -m 0755 ${WORKDIR}/can-pre-up ${D}${sysconfdir}/network/can-pre-up
    fi
}
