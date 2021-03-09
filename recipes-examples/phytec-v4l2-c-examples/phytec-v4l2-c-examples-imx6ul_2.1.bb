# Copyright (C) 2017 Stefan Riedmüller <s.riedmueller@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Phytec video4linux2 examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SECTION = "examples"

# Archive created with
#   $ unzip v4l2-c_examples.zip
#   $ mv v4l2-c_examples_V2.0 phytec-v4l2-c-examples-imx6ul-2.0
#   $ find phytec-v4l2-c-examples-imx6ul-2.0 -exec "touch" "{}" ";"
#   $ find phytec-v4l2-c-examples-imx6ul-2.0 -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-v4l2-c-examples-imx6ul-2.0.tar.gz phytec-v4l2-c-examples-imx6ul-2.0/

SRC_URI = "https://download.phytec.de/Software/Linux/Applications/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "957657c661c647c76dc6da50ca6669d0"
SRC_URI[sha256sum] = "8a313796f0c849ac4697cdd1e6b7b39f58451210be0934019d7decdbdff1d209"

PR = "r0"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    INSTALL_DIR="${datadir}/phytec-v4l2-c-examples"

    install -d ${D}${INSTALL_DIR}
    for text in `find -name '*.txt'`; do
        install -m 0644 ${text} ${D}${INSTALL_DIR}/${text}
    done

    for scripts in `find -name '*.sh'`; do
        install -m 0755 ${scripts} ${D}${INSTALL_DIR}/${scripts}
    done

    # Create link in home folder for old documentation
    install -d ${D}${ROOT_HOME}
    ln -s ${INSTALL_DIR} ${D}${ROOT_HOME}/v4l2_c-examples
}

FILES_${PN} += " \
    ${ROOT_HOME}/ \
    ${datadir}/phytec-v4l2-c-examples \
"
RDEPENDS_${PN} += " \
    media-ctl \
    bvtest \
    phytec-gstreamer-examples-imx6ul \
"
