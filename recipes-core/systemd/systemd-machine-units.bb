SUMMARY = "Machine specific systemd units"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PR = "r23"
inherit systemd

ALLOW_EMPTY_${PN} = "1"

# Don't generate empty -dbg package
PACKAGES = "${PN}"

SRC_URI = " \
    file://10-eth0.network \
    file://10-eth1.network \
    file://90-dhcp-default.network \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can0.service", "", d)} \
"

SYSTEMD_SERVICE_${PN} = "${@bb.utils.contains("MACHINE_FEATURES", "can", "can0.service", "", d)}"

do_install() {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.network); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_system_unitdir}/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.service); do
        install -m 0644 "$file" ${D}${systemd_system_unitdir}/
    done
}

FILES_${PN} = "\
    ${systemd_system_unitdir} \
    ${systemd_unitdir}/network/ \
"
