DESCRIPTION = "Phytec video4linux2 examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SECTION = "examples"

# Archive created with
#   $ unzip v4l2-c_examples.zip
#   $ mv v4l2-c_examples phytec-v4l2-c-examples-imx8m-1.2
#   $ find phytec-v4l2-c-examples-imx8m-1.2 -exec "touch" "{}" ";"
#   $ find phytec-v4l2-c-examples-imx8m-1.2 -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-v4l2-c-examples-imx8m-1.2.tar.gz phytec-v4l2-c-examples-imx8m-1.2/

SRC_URI = "ftp://ftp.phytec.de/pub/Software/Linux/Applications/${PN}-${PV}.tar.gz"
SRC_URI[md5sum] = "374b99ce58798528ca69027be1f0db94"
SRC_URI[sha256sum] = "fe974ff5cd390d8b00f83faba7eaa81f72b7c18c74cf2a528bffc67d2cefdd7c"

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
