FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://weston.ini"

SRC_URI_append = " ${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'file://weston.conf', '', d)}"

HAS_XWAYLAND = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'true', 'false', d)}"

do_install_append() {
    if ${HAS_XWAYLAND}; then
       install -Dm0755 ${WORKDIR}/weston.conf ${D}${sysconfdir}/default/weston
    fi
}

