# Copyright (C) 2015 PHYTEC Messtechnik GmbH
# Author: Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
DESCRIPTION = "this brings up a demo for our dev kits"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = " \
    file://qt5demo.service \
"

inherit systemd

PR = "r1"

SYSTEMD_SERVICE_${PN} = "qt5demo.service"

# Don't generate '-dev' and '-dbg' packages, since they are empty.
PACKAGES = "${PN}"

# The resutling packages are machine dependent, because the qt5demo.service
# unit is different for ti335x and mx6 machines.
PACKAGE_ARCH = "${MACHINE_ARCH}"

do_install() {
    install -Dm 0644 ${WORKDIR}/qt5demo.service ${D}${systemd_unitdir}/system/qt5demo.service
}
FILES_${PN} = "${bindir} ${systemd_unitdir}"
RDEPENDS_${PN} += "qt5everywheredemo"
