SUMMARY = "Chromium Systemd Autostart"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit features_check
inherit systemd

SRC_URI = "\
            file://chromium.service \
          "

SYSTEMD_AUTO_ENABLE:${PN} = "enable"
SYSTEMD_PACKAGES = "${PN}"

SYSTEMD_SERVICE:${PN} = "chromium.service"

do_install() {
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${WORKDIR}/chromium.service ${D}${systemd_system_unitdir}
}

FILES:${PN} += "${systemd_system_unitdir}/chromium.service"

REQUIRED_DISTRO_FEATURES= " systemd"
