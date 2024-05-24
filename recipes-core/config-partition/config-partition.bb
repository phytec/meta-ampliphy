DESCRIPTION = "Populate config partition"
HOMEPAGE = "https://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy
S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install () {
        install -d ${D}/rauc
}

FILES:${PN} = "rauc/"

do_deploy () {
        tar -czf ${B}/config-partition.tar.gz -C ${D}/ . --owner=0 --group=0
        install -m 644 ${B}/config-partition.tar.gz ${DEPLOYDIR}
}

addtask deploy after do_install
