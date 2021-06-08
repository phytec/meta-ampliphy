DESCRIPTION = "Development PHYTEC CA with test keys.\
                Please create and use your own certificates and keys!"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit pkgconfig

SRC_URI = " \
    https://download.phytec.de/Software/Linux/Applications/phytec-dev-ca-${PV}.tar.gz;name=tarball \
"

INSANE_SKIP_${PN} += "already-stripped"

S = "${WORKDIR}"
DEVCA = "phytec-dev-ca"

do_install() {
    if echo "${CERT_PATH}" | grep -q "${DEVCA}"; then
        install -d ${CERT_PATH}
        cp -r ${B}/${DEVCA}/* ${CERT_PATH}
    fi
}

do_cleanall_append() {
    import shutil
    import os
    src_uri = (d.getVar('CERT_PATH') or "")
    devca = (d.getVar('DEVCA') or "")
    if len(src_uri) == 0:
        return
    if devca not in src_uri:
        return
    if os.path.exists(src_uri):
        shutil.rmtree(src_uri)
}

BBCLASSEXTEND = "native"
