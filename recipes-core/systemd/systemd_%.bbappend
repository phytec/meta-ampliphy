FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd"

SRC_URI_append = " \
    file://eth0.network \
    file://eth1.network \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can0.service", "", d)} \
    file://0001-networkd-Begin-with-serial-number-1-for-netlink-requ.patch \
    file://0001-sd-rtnl-never-set-serial-to-0.patch \
    file://0001-sd-rtnl-improve-detection-of-broadcast-messages.patch \
    file://0001-sd-rtnl-process-only-apply-matches-to-broadcast-mess.patch \
"

do_install_append () {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.network); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_unitdir}/system/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.service); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/system/
    done

    if [ -f ${D}${systemd_unitdir}/system/can0.service ]
    then
        install -d ${D}${sysconfdir}/systemd/system/basic.target.wants
        ln -sf ${systemd_unitdir}/system/can0.service ${D}${sysconfdir}/systemd/system/basic.target.wants/can0.service
    fi

}
