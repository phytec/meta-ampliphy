# Copyright (C) 2015 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "This is a demo software showing some Qt Features"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

DEPENDS = "qtbase qtdeclarative"

# The resutling packages are machine dependent, because the phytec-qtdemo.service
# unit is different for ti33x machines.
PACKAGE_ARCH = "${MACHINE_ARCH}"
PR = "r0"

SRC_URI = " \
    git://git.phytec.de/phyRDKDemo \
    file://phytec-qtdemo.service \
"
SRCREV = "17ce6c53eb8d95301915aae14f0f3c7051840ee7"
PV = "0.4+git${SRCPV}"

S = "${WORKDIR}/git"

inherit qmake5 systemd

SYSTEMD_SERVICE_${PN} = "phytec-qtdemo.service"

PACKAGES += "${PN}-htmlcontent"

FILES_${PN} = "${datadir} ${bindir} ${systemd_unitdir}"
FILES_${PN}-dbg = "${datadir}/${PN}/.debug"
FILES_${PN}-dev = "/usr/src"
FILES_${PN}-htmlcontent = "${datadir}/${PN}/html"

RDEPENDS_${PN} = "qtgraphicaleffects-qmlplugins qtmultimedia-qmlplugins qtfreevirtualkeyboard"
RRECOMMENDS_${PN} += "${PN}-htmlcontent"

do_install_append() {
    install -d ${D}${bindir}
    ln -sf ${datadir}/${PN}/phytec-qtdemo ${D}${bindir}/QtDemo
    install -Dm 0644 ${WORKDIR}/phytec-qtdemo.service ${D}${systemd_unitdir}/system/phytec-qtdemo.service

    #htmlcontent
    cp -r ${S}/phytec_offline ${D}${datadir}/${PN}/html
}
