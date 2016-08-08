# Copyright (C) 2016 Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Phytec video4linux2 examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SECTION = "examples"

# Archive created with
#   $ unzip v4l2_c-examples.zip
#   $ mv v4l2_c-examples_V1.0\ -\ Kopie/ phytec-v4l2-c-examples-0.4
#   $ find phytec-v4l2-c-examples-0.4 -exec "touch" "{}" ";"
#   $ find phytec-v4l2-c-examples-0.4 -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-v4l2-c-examples-0.4.tar.gz phytec-v4l2-c-examples-0.4/
SRC_URI = "file://${PN}-${PV}.tar.gz"

PR = "r0"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    INSTALL_DIR="${datadir}/${PN}"

    install -d ${D}${INSTALL_DIR}
    for text in `find -name '*.txt'`; do
        install -m 0644 ${text} ${D}${INSTALL_DIR}/${text}
    done

    for scripts in `find -name '*.sh'`; do
        install -m 0755 ${scripts} ${D}${INSTALL_DIR}/${scripts}
    done

    # Create link in home folder for old documentation
    install -d ${D}/home/root
    ln -s ${INSTALL_DIR} ${D}/home/root/v4l2_c-examples
}

FILES_${PN} += "/home/root/"
RDEPENDS_${PN} += " \
    media-ctl \
    bvtest \
    phytec-gstreamer-examples \
"
