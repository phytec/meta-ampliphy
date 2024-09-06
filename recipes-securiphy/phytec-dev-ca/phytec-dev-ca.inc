DESCRIPTION = "Development PHYTEC CA with test keys.\
                Please create and use your own certificates and keys!"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit pkgconfig

SRC_URI = "https://github.com/phytec/phytec-dev-ca/releases/download/v${PV}/phytec-dev-ca-${PV}.tar.gz"

INSANE_SKIP:${PN} += "already-stripped"

S = "${WORKDIR}/${BPN}-${PV}"

do_install() {
    if [ -z "${CERT_PATH}" ]; then
        bbfatal "${BPN} requires CERT_PATH to be set!"
    fi

    install -d ${CERT_PATH}
    cp -r ${S}/* ${CERT_PATH}/
}
do_install[vardeps] += "CERT_PATH"

python do_cleanall:append() {
    import shutil
    import os
    cert_path = d.getVar('CERT_PATH')
    if os.path.isdir(cert_path):
        shutil.rmtree(cert_path)
}

BBCLASSEXTEND = "native"
