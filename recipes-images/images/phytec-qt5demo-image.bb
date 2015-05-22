# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)
SUMMARY =  "This image is designed to be a development image for Qt 5 \
            Embedded userspace applications."

require phytec-hwbringup-image.bb

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs"

LICENSE = "MIT"

inherit core-image distro_features_check populate_sdk_qt5

# this is a pure qt5 embedded demo image without X
CONFLICT_DISTRO_FEATURES = "x11 wayland"
REQUIRED_DISTRO_FEATURES = "opengl"

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    qtbase \
    qtbase-plugins \
    qtbase-fonts \
    qtsvg \
    qtsvg-plugins \
    qtdeclarative \
    qtdeclarative-plugins \
    qtdeclarative-qmlplugins \
    qtquickcontrols-qmlplugins \
    qtmultimedia \
    qtmultimedia-plugins \
    qtmultimedia-qmlplugins \
    qt5everywheredemo \
    qt5-opengles2-test \
    ${@bb.utils.contains('DISTRO_FEATURES','autostart-demo','qt5demo-autostarter','',d)} \
"

IMAGE_INSTALL_append_mx6 = " packagegroup-gstreamer"
