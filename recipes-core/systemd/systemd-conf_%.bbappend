FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

inherit systemd

# ethernet interface numbering of fpsc-g starts with 1
FIRST_END_DEVICE = "0"
FIRST_END_DEVICE:phyflex-fpsc-g = "1"

SRC_URI += " \
    file://10-wait-online-any.conf \
    file://10-watchdog.conf \
    ${@bb.utils.contains('FIRST_END_DEVICE', '0', ' file://10-end0.network', '', d)} \
    file://10-end1.network \
    file://10-end2.network \
    file://10-end3.network \
    file://10-end4.network \
    file://10-ethernet.link \
    file://11-can.network \
    file://11-fcan.network \
    file://90-dhcp-default.network \
"

SRC_URI:append:mx6ul-generic-bsp = " file://cpuidle-disable-state.rules"
SRC_URI:append:mx8-generic-bsp = " file://45-disable-multitouch-mouse.rules"
SRC_URI:append:mx95-generic-bsp = " file://37-can-imx-soc.rules"
SRC_URI:append:ti-soc =  " file://37-can-ti-soc.rules"
SRC_URI:append:ti33x = " \
    file://11-dcan.network \
"
SRC_URI:append:am57xx = " \
    file://11-dcan.network \
"
SRC_URI:append:k3 = " \
    file://11-main_mcan.network \
    file://11-mcu_mcan.network \
    file://86-k3-remoteproc.rules \
"

do_install:append() {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name "*.network"); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name "*.link"); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_system_unitdir}/
    for file in $(find ${UNPACKDIR} -maxdepth 1 -type f -name "*.service"); do
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

    if [ -e ${UNPACKDIR}/37-can-imx-soc.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/37-can-imx-soc.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${UNPACKDIR}/37-can-ti-soc.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/37-can-ti-soc.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${UNPACKDIR}/86-k3-remoteproc.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/86-k3-remoteproc.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    if [ -e ${UNPACKDIR}/45-disable-multitouch-mouse.rules ]; then
        install -d ${D}${sysconfdir}/udev/rules.d
        install -m 0644 ${UNPACKDIR}/45-disable-multitouch-mouse.rules ${D}${sysconfdir}/udev/rules.d/
    fi

    rm -rf ${D}${systemd_unitdir}/network/wired.network
    rm -rf ${D}${systemd_unitdir}/network/80-wired.network
}

do_install:append:phyboard-segin() {
    sed -i '/^FDMode/d' ${D}${systemd_unitdir}/network/11-can.network
    sed -i '/^DataBitRate/d' ${D}${systemd_unitdir}/network/11-can.network
}

# first interface should always have the ip 192.168.3.11
do_install:append:phyflex-fpsc-g() {
    path='${D}${systemd_unitdir}/network/'

    sed -i 's#^\(Address=192.168.\)4\(.11\/24\)#\13\2#' ${path}/10-end1.network
    sed -i 's#^\(Address=192.168.\)5\(.11\/24\)#\14\2#' ${path}/10-end2.network
    sed -i 's#^\(Address=192.168.\)6\(.11\/24\)#\15\2#' ${path}/10-end3.network
    sed -i 's#^\(Address=192.168.\)7\(.11\/24\)#\16\2#' ${path}/10-end4.network
}

FILES:${PN} += "\
    ${systemd_system_unitdir} \
    ${sysconfdir}/udev/rules.d \
"
