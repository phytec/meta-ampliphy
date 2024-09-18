FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini \
            file://weston.env"

do_install:append:mx8-nxp-bsp() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        # Weston should be run as weston, not as root
        sed -i -e "s,User=root,User=weston," ${D}${systemd_system_unitdir}/weston.service
        sed -i -e "s,Group=root,Group=weston," ${D}${systemd_system_unitdir}/weston.service
    fi
}
