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
SRC_URI:append:am62xx = " \
    file://11-main_mcan0.network \
    file://11-mcu_mcan0.network \
    file://11-mcu_mcan1.network \
"
SRC_URI:append:am62axx = " \
    file://11-main_mcan0.network \
    file://11-mcu_mcan0.network \
    file://11-mcu_mcan1.network \
"
SRC_URI:append:am64xx = " \
    file://11-main_mcan0.network \
    file://11-main_mcan1.network \
"
SRC_URI:append:j721s2 = " \
    file://11-main_mcan0.network \
    file://11-main_mcan1.network \
    file://11-main_mcan13.network \
    file://11-main_mcan16.network \
    file://11-main_mcan2.network \
    file://11-mcu_mcan0.network \
    file://11-mcu_mcan1.network \
"

do_install:append() {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name *.network); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name *.link); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_system_unitdir}/
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name *.service); do
        install -m 0644 "$file" ${D}${systemd_system_unitdir}/
    done
    install -d ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/
    install -m 0644 ${UNPACKDIR}/10-wait-online-any.conf ${D}${systemd_system_unitdir}/systemd-networkd-wait-online.service.d/

    [ -e ${UNPACKDIR}/10-watchdog.conf ] && \
      install -m 0644 ${UNPACKDIR}/10-watchdog.conf ${D}${systemd_unitdir}/system.conf.d/10-watchdog.conf

    if [ -e ${UNPACKDIR}/cpuidle-disable-state.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/cpuidle-disable-state.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${UNPACKDIR}/37-can-ti-soc.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/37-can-ti-soc.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${UNPACKDIR}/45-disable-multitouch-mouse.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/45-disable-multitouch-mouse.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    rm -rf ${D}${systemd_unitdir}/network/wired.network
    rm -rf ${D}${systemd_unitdir}/network/80-wired.network
}

FILES:${PN} += "\
    ${systemd_system_unitdir} \
    ${sysconfdir}/udev/rules.d \
"
