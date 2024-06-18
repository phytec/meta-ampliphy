FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://weston.ini \
    file://weston-socket.sh \
"

do_install:append() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        install -D -p -m0644 ${WORKDIR}/weston-socket.sh ${D}${sysconfdir}/profile.d/weston-socket.sh
    fi
}
