# Copyright (C) 2015 PHYTEC Messtechnik GmbH
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "This is a demo software showing some Qt Features"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT & CC-BY-3.0"
LIC_FILES_CHKSUM = " \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
    file://${COMMON_LICENSE_DIR}/CC-BY-3.0;md5=dfa02b5755629022e267f10b9c0a2ab7 \
"

DEPENDS = " \
    qtbase \
    qtdeclarative \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston-init', '', d)} \
"

# The resutling packages are machine dependent, because the phytec-qtdemo.service
# unit is different for ti33x machines.
PACKAGE_ARCH = "${MACHINE_ARCH}"
PR = "r0"

SERVICE = "${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'phytec-qtdemo-wl.service', 'phytec-qtdemo.service', d)}"
SRC_URI = " \
    git://git.phytec.de/phyRDKDemo;branch=master \
    file://PhyKitDemo.conf \
    file://${SERVICE} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'file://phytec-qtdemo-wl.rules', '', d)} \
"

SRCREV = "5fd5a82ccee3347be2b9bc61f13ee604b9ae22fd"
PV = "1.6+git${SRCPV}"

S = "${WORKDIR}/git"

inherit qmake5 systemd

SYSTEMD_SERVICE:${PN} = "phytec-qtdemo.service"

PACKAGES += "${PN}-democontent ${PN}-videos"

FILES:${PN} = "\
    ${datadir} \
    ${bindir} \
    ${systemd_unitdir} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '/home/weston/.config', '${ROOT_HOME}/.config', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', '${nonarch_base_libdir}', '', d)} \
"
FILES:${PN} = "${datadir} ${bindir} ${systemd_unitdir} ${ROOT_HOME}/.config"
FILES:${PN}-dbg = "${datadir}/${BPN}/.debug"
FILES:${PN}-dev = "/usr/src"
FILES:${PN}-democontent = "${datadir}/${BPN}/images"
FILES:${PN}-video = "${datadir}/${BPN}/videos"
LICENSE:${PN}-video = "CC-BY-3.0"

RDEPENDS:${PN} += "\
    qtmultimedia-qmlplugins \
    qtvirtualkeyboard \
    qtquickcontrols2-qmlplugins \
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

RDEPENDS:${PN}:remove:mx6ul = "\
    qtmultimedia-qmlplugins \
"

RDEPENDS:${PN}:remove:mx7d = "\
    qtmultimedia-qmlplugins \
"

RRECOMMENDS:${PN} += "${PN}-democontent ${PN}-videos"

do_install:append() {
    install -d ${D}${bindir}
    ln -sf ${datadir}/${BPN}/phytec-qtdemo ${D}${bindir}/QtDemo
    install -Dm 0644 ${WORKDIR}/${SERVICE} ${D}${systemd_system_unitdir}/phytec-qtdemo.service

    if ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'true', 'false', d)}; then
        install -Dm 0644 -o weston -g weston ${WORKDIR}/PhyKitDemo.conf ${D}/home/weston/.config/Phytec/PhyKitDemo.conf
        install -d ${D}${nonarch_base_libdir}/udev/rules.d/
        install -m 0644 ${WORKDIR}/phytec-qtdemo-wl.rules ${D}${nonarch_base_libdir}/udev/rules.d/
    else
        install -Dm 0644 ${WORKDIR}/PhyKitDemo.conf ${D}${ROOT_HOME}/.config/Phytec/PhyKitDemo.conf
    fi

    # democontent
    install -d ${D}${datadir}/${BPN}/images
    for f in ${S}/images/page_phytec_*.png; do \
        install -Dm 0644 $f ${D}${datadir}/${BPN}/images/
    done

    # videos
    install -Dm 0644 ${S}/media/caminandes.webm ${D}${datadir}/${BPN}/videos/caminandes.webm
}
