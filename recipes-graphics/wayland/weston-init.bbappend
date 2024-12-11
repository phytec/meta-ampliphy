FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini \
            file://weston.env \
            ${@bb.utils.contains("MACHINE_FEATURES", "resistivetouch", " \
                file://res-touchscreen.rules \
                file://calibrate-res-touchscreen.sh", "", d)} \
"

do_install:append() {
    if [ -e ${WORKDIR}/res-touchscreen.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/res-touchscreen.rules ${D}${sysconfdir}/udev/rules.d

        install -d ${D}${bindir}
        install -m 0774 ${WORKDIR}/calibrate-res-touchscreen.sh ${D}${bindir}
    fi
}

do_install:append:mx8-nxp-bsp() {
    if ${@bb.utils.contains('DISTRO_FEATURES','systemd','true','false',d)}; then
        # Weston should be run as weston, not as root
        sed -i -e "s,User=root,User=weston," ${D}${systemd_system_unitdir}/weston.service
        sed -i -e "s,Group=root,Group=weston," ${D}${systemd_system_unitdir}/weston.service
    fi
}

FILES:${PN} += " \
    ${sysconfdir}/udev/rules.d \
    ${bindir}/calibrate-res-touchscreen.sh \
"
