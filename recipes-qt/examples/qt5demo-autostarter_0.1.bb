# Copyright (C) 2015 PHYTEC Messtechnik GmbH
# Author: Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
DESCRIPTION = "this brings up a demo for our dev kits"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"
PR = "r0"

SRC_URI = " \
    file://qt5demo-starter \
    file://qt5demo.service \
"

inherit systemd

SYSTEMDSERVICE_${PN} = "qt5demo.service"

do_install() {
    install -d  ${D}${systemd_unitdir}/system \
                ${D}${systemd_unitdir}/system/multi-user.target.wants \
                ${D}${bindir}
    install -m 0755 ${WORKDIR}/qt5demo-starter ${D}${bindir}
    install -m 0644 ${WORKDIR}/qt5demo.service ${D}${systemd_unitdir}/system
    ln -fs ../qt5demo.service ${D}${systemd_unitdir}/system/multi-user.target.wants/qt5demo.service
}
FILES_${PN} = "${bindir} ${systemd_unitdir}"
