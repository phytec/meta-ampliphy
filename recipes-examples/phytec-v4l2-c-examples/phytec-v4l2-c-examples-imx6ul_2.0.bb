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

SRC_URI = "ftp://ftp.phytec.de/pub/Software/Linux/Applications/${PN}-${PV}.tar.gz"
SRC_URI[md5sum] = "5267f6a59a6a8860d8646e5df86d1d80"
SRC_URI[sha256sum] = "9565d8b92529b84928896707e1359b3d9eac150cbd97e19315ff8d3b09b87303"

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
    install -d ${D}/home/root
    ln -s ${INSTALL_DIR} ${D}/home/root/v4l2_c-examples
}

FILES_${PN} += " \
    /home/root/ \
    ${datadir}/phytec-v4l2-c-examples \
"
RDEPENDS_${PN} += " \
    media-ctl \
    bvtest \
    phytec-gstreamer-examples-imx6ul \
"
