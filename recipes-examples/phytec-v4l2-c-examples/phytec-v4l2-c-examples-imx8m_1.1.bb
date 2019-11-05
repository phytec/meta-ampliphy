DESCRIPTION = "Phytec video4linux2 examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SECTION = "examples"

# Archive created with
#   $ unzip v4l2-c_examples.zip
#   $ mv v4l2-c_examples_V2.0 phytec-v4l2-c-examples-imx8m-2.0
#   $ find phytec-v4l2-c-examples-imx8m-2.0 -exec "touch" "{}" ";"
#   $ find phytec-v4l2-c-examples-imx8m-2.0 -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-v4l2-c-examples-imx8m-2.0.tar.gz phytec-v4l2-c-examples-imx8m-2.0/

SRC_URI = "ftp://ftp.phytec.de/pub/Software/Linux/Applications/${PN}-${PV}.tar.gz"
SRC_URI[md5sum] = "88f91556cbdcaf00762c4592f16648b2"
SRC_URI[sha256sum] = "5682875591a57bc3298955bac4743cf6189af5e31747b5a7d438422f03bfef1c"

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
    phytec-gstreamer-examples-imx8m \
"
