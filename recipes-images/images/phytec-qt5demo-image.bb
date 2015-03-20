# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)
SUMMARY =  "This image is designed to be a development image for Qt 5 \
            Embedded userspace applications."

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs"

LICENSE = "MIT"

inherit core-image distro_features_check

# this is a pure qt5 embedded demo image without X
CONFLICT_DISTRO_FEATURES = "x11 wayland"
REQUIRED_DISTRO_FEATURES = "opengl"

IMAGE_INSTALL = " \
    packagegroup-core-boot \
    packagegroup-base \
    packagegroup-hwtools \
    packagegroup-benchmark \
    packagegroup-userland \
    ${@bb.utils.contains("DISTRO_FEATURES", "mtd-tests", "packagegroup-mtdtests", "", d)} \
    \
    qtbase \
    qtbase-plugins \
    qtbase-fonts \
    qtsvg \
    qtsvg-plugins \
    qtdeclarative \
    qtdeclarative-plugins \
    qtdeclarative-qmlplugins \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    cinematicexperience \
    qtsmarthome \
"
