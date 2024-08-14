FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

inherit systemd

SRC_URI += " \
    file://10-wait-online-any.conf \
    file://10-watchdog.conf \
    file://10-eth0.network \
    file://10-eth1.network \
    file://10-eth2.network \
    file://10-eth0.link \
    file://10-eth1.link \
    file://10-eth2.link \
    file://11-can0.network \
    file://11-can1.network \
    file://90-dhcp-default.network \
"

SRC_URI:append:mx6ul-generic-bsp = " file://cpuidle-disable-state.rules"
SRC_URI:append:mx8-generic-bsp = " file://45-disable-multitouch-mouse.rules"
SRC_URI:append:ti-soc =  " file://37-can-ti-soc.rules"
SRC_URI:append:ti33x = " \
    file://11-dcan0.network \
    file://11-dcan1.network \
"
SRC_URI:append:am57xx = " \
    file://11-dcan1.network \
    file://11-dcan2.network \
"

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
    install -d ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/
    install -m 0644 ${WORKDIR}/10-wait-online-any.conf ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/

    [ -e ${WORKDIR}/10-watchdog.conf ] && \
      install -m 0644 ${WORKDIR}/10-watchdog.conf ${D}${systemd_unitdir}/system.conf.d/10-watchdog.conf

    if [ -e ${WORKDIR}/cpuidle-disable-state.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/cpuidle-disable-state.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${WORKDIR}/37-can-ti-soc.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${WORKDIR}/37-can-ti-soc.rules ${D}${sysconfdir}/udev/rules.d/
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
