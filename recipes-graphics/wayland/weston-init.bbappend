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

# On K3 machines with linux-phytec (upstream Imagination / Mesa / Zink stack),
# the PowerVR Vulkan driver only loads when PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1
# is set.
PVR_BROKEN_VULKAN = "${@oe.utils.conditional('PREFERRED_PROVIDER_virtual/kernel', 'linux-phytec', '1', '0', d)}"

do_install:append:k3() {
    if [ "${PVR_BROKEN_VULKAN}" = "1" ]; then
        install -d ${D}${sysconfdir}/default
        echo 'PVR_I_WANT_A_BROKEN_VULKAN_DRIVER=1' >> ${D}${sysconfdir}/default/weston
    fi
}

FILES:${PN} += " \
    ${sysconfdir}/udev/rules.d \
    ${bindir}/calibrate-res-touchscreen.sh \
"
