# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Custom Vision demo application using Qt"
HOMEPAGE = "https://www.phytec.de"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://../../../LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"

DEPENDS = " \
    qtbase \
    qtmultimedia \
    qtdeclarative \
"

SRC_URI = "git://git.phytec.de/aidemo-customvision"
SRCREV = "3a933c00fc5d35ca344df3a90ab85ad8b1d2715a"
S = "${WORKDIR}/git/modules/demo/src"

inherit qmake5

RDEPENDS_${PN} += " \
    qtbase \
    qtmultimedia-qmlplugins \
    qtquickcontrols2-qmlplugins \
    gstreamer1.0-plugins-bad \
"
FILES_${PN} = "${bindir}"
