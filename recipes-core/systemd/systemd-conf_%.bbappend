FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

inherit systemd

SRC_URI += " \
    file://10-watchdog.conf \
    file://10-eth0.network \
    file://10-eth1.network \
    file://10-eth0.link \
    file://10-eth1.link \
    file://90-dhcp-default.network \
    file://can0.network \
    file://can1.network \
"

SRC_URI:append:mx6ul-generic-bsp = " file://cpuidle-disable-state.rules"
SRC_URI:append:mx8 = " file://45-disable-multitouch-mouse.rules"

do_install:append() {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.network); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.link); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_system_unitdir}/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.service); do
        install -m 0644 "$file" ${D}${systemd_system_unitdir}/
    done

    [ -e ${WORKDIR}/10-watchdog.conf ] && \
      install -m 0644 ${WORKDIR}/10-watchdog.conf ${D}${systemd_unitdir}/system.conf.d/10-watchdog.conf

    if [ -e ${WORKDIR}/cpuidle-disable-state.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/cpuidle-disable-state.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${WORKDIR}/45-disable-multitouch-mouse.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/45-disable-multitouch-mouse.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    rm -rf ${D}${systemd_unitdir}/network/wired.network
    rm -rf ${D}${systemd_unitdir}/network/80-wired.network
}

FILES:${PN} += "\
    ${systemd_system_unitdir} \
    ${sysconfdir}/udev/rules.d \
"
