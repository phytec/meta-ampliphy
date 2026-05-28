DESCRIPTION = "RAUC artifacts example application"
HOMEPAGE = "https://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = " \
    file://${BPN}.sh \
    https://download.phytec.de/Software/Linux/Applications/Media/phytec_logo_small.png \
"
SRC_URI[sha256sum] = "ec39d79d7188d51e75989a604cc7c31bb81228790c5d7b16ba4127006e6ba3c1"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

inherit rauc-artifact

do_install() {
    install -m 0755 ${UNPACKDIR}/${BPN}.sh ${D}
    install -m 0644 ${UNPACKDIR}/phytec_logo_small.png ${D}
}

FILES:${PN} = "/"
