# Copyright (C) 2015 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "This is a demo software showing some Qt Features"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT & CC-BY-3.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/CC-BY-3.0;md5=dfa02b5755629022e267f10b9c0a2ab7 \
"

DEPENDS = "qtbase qtdeclarative"

# The resutling packages are machine dependent, because the phytec-qtdemo.service
# unit is different for ti33x machines.
PACKAGE_ARCH = "${MACHINE_ARCH}"
PR = "r0"

SRC_URI = " \
    git://git.phytec.de/phyRDKDemo \
    file://phytec-qtdemo.service \
    file://PhyKitDemo.conf \
"
SRCREV = "f2ede77804bc7783ff31ff7075ce34cb186f379a"
PV = "0.5+git${SRCPV}"

S = "${WORKDIR}/git"

inherit qmake5 systemd

SYSTEMD_SERVICE_${PN} = "phytec-qtdemo.service"

PACKAGES += "${PN}-democontent ${PN}-videos"

FILES_${PN} = "${datadir} ${bindir} ${systemd_unitdir} /.config"
FILES_${PN}-dbg = "${datadir}/${PN}/.debug"
FILES_${PN}-dev = "/usr/src"
FILES_${PN}-democontent = "${datadir}/${PN}/html ${datadir}/${PN}/images"
FILES_${PN}-video = "${datadir}/${PN}/videos"
LICENSE_${PN}-video = "CC-BY-3.0"

RDEPENDS_${PN} += "\
    qtgraphicaleffects-qmlplugins \
    qtmultimedia-qmlplugins \
    qtfreevirtualkeyboard \
    qtquickcontrols-qmlplugins \
    qtbase-fonts \
    qtwebkit \
"
RRECOMMENDS_${PN} += "${PN}-democontent ${PN}-videos"

do_install_append() {
    install -d ${D}${bindir}
    ln -sf ${datadir}/${PN}/phytec-qtdemo ${D}${bindir}/QtDemo
    install -Dm 0644 ${WORKDIR}/phytec-qtdemo.service ${D}${systemd_system_unitdir}/phytec-qtdemo.service
    install -Dm 0644 ${WORKDIR}/PhyKitDemo.conf ${D}/.config/Phytec/PhyKitDemo.conf

    # democontent
    install -d ${D}${datadir}/${PN}/html
    cp -r ${S}/phytec_offline/* ${D}${datadir}/${PN}/html
    install -d ${D}${datadir}/${PN}/images
    for f in ${S}/images/page_phytec_*.png; do \
        install -Dm 0644 $f ${D}${datadir}/${PN}/images/
    done

    # videos
    install -Dm 0644 ${S}/media/caminandes.webm ${D}${datadir}/${PN}/videos/caminandes.webm
}
