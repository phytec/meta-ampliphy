DESCRIPTION = "Development PHYTEC CA with test keys.\
                Please create and use your own certificates and keys!"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit pkgconfig

SRC_URI = "https://github.com/phytec/phytec-dev-ca/releases/download/v${PV}/phytec-dev-ca-${PV}.tar.gz"

do_install[nostamp] = "1"

do_patch[noexec] = "1"
do_configure[noexec] = "1"
do_compile[noexec] = "1"
INSANE_SKIP:${PN} += "already-stripped"

S = "${UNPACKDIR}"
DEVCA_DIR = "${TOPDIR}/../${BPN}"

do_install() {
    cp -r ${S}/${BPN}-${PV}/* ${DEVCA_DIR}
}
do_install[vardeps] += "DEVCA_DIR"
do_install[cleandirs] += "${DEVCA_DIR}"

python do_cleanall:append() {
    import shutil
    import os
    devca_dir = d.getVar('DEVCA_DIR')
    if os.path.isdir(devca_dir):
        shutil.rmtree(devca_dir)
}

BBCLASSEXTEND = "native"
