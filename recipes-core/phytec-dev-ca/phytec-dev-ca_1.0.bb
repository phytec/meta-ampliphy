# Copyright (C) 2020 Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Development PHYTEC CA with test keys.\
                Please create and use your own certificates and keys!"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit pkgconfig

SRC_URI = " \
    ftp://ftp.phytec.de/pub/Software/Linux/Applications/phytec-dev-ca-${PV}.tar.gz;name=tarball \
"

SRC_URI[tarball.md5sum] = "2dc3fe8eb55c39c1435a942e5b7cd11f"
SRC_URI[tarball.sha256sum] = "000e54175ff34254f521b097ec98961658cc9c8338e72f78d93c4cb0f20c8e7c"

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
