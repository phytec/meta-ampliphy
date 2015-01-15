DESCRIPTION = "Task to add Qt embedded related packages"
LICENSE = "MIT"
PR = "r7"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

QT4_SGX_SUPPORT = "\
    qt4-embedded-plugin-gfxdriver-gfxpvregl \
    libqt-embeddedopengl4 \
    libqt-embeddedpvrqwswsegl4 \
"

QT4_ESSENTIALS = "\
    qt4-embedded \
    qt4-embedded-plugin-mousedriver-tslib \
    qt4-embedded-plugin-gfxdriver-gfxtransformed \
    qt4-embedded-plugin-phonon-backend-gstreamer \
    qt4-embedded-plugin-imageformat-gif \
    qt4-embedded-plugin-imageformat-jpeg \
    qt4-embedded-qml-plugins \
    libqt-embeddedmultimedia4 \
    libqt-embeddeddeclarative4 \
    libqt-embeddedxmlpatterns4 \
    ${QT4_SGX_SUPPORT} \
"

RDEPENDS_${PN} = "\
    ${QT4_ESSENTIALS} \
"
