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
SRCREV = "a87a81f12e2819d5ea79d93a4239476e28d90d0b"
PV = "0.6+git${SRCPV}"

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
    qtvirtualkeyboard \
    qtquickcontrols-qmlplugins \
    ttf-dejavu-sans \
    ttf-dejavu-sans-mono \
    ttf-dejavu-serif \
    qtwebkit \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-base-audioconvert \
    gstreamer1.0-plugins-base-audioresample \
    gstreamer1.0-plugins-base-playback \
    gstreamer1.0-plugins-base-typefindfunctions \
    gstreamer1.0-plugins-base-videoconvert \
    gstreamer1.0-plugins-base-videoscale \
    gstreamer1.0-plugins-base-volume \
    gstreamer1.0-plugins-base-vorbis \
    gstreamer1.0-plugins-good-autodetect \
    gstreamer1.0-plugins-good-matroska \
    gstreamer1.0-plugins-good-ossaudio \
    gstreamer1.0-plugins-good-videofilter \
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
