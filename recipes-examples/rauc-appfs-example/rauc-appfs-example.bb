DESCRIPTION = "RAUC appfs example application"
HOMEPAGE = "https://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI += "file://rauc-appfs-example.sh"

S = "${WORKDIR}"
B = "${WORKDIR}/build"

RDEPENDS:${PN} = "busybox"

inherit deploy

APPFSDIR = "${WORKDIR}/image-appfs"
do_appfs() {
    install -m 0755 ${WORKDIR}/rauc-appfs-example.sh ${APPFSDIR}/${BPN}
}
do_appfs[dirs] = "${APPFSDIR}"
do_appfs[cleandirs] = "${B}"
addtask appfs after do_compile before do_install

do_deploy() {
    tar -czf ${B}/${BPN}.tar.gz -C ${APPFSDIR} . --owner=0 --group=0
    install -m 0644 ${B}/${BPN}.tar.gz ${DEPLOYDIR}
}
addtask deploy after do_install before do_build
