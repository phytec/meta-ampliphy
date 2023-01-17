SUMMARY = "A KMS/DRM screenshot tool"
HOMEPAGE = "https://github.com/pcercuei/kmsgrab"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/files/common-licenses/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

PV = "1.0"
PR = "r0"

BRANCH = "main"
SRC_URI = "git://github.com/pcercuei/kmsgrab.git;protocol=https;branch=${BRANCH}"
SRCREV = "22916bdc63b133e52079a699ae6b2d25d990e798"

DEPENDS = "libdrm libpng"

S = "${WORKDIR}/git"

inherit cmake pkgconfig

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/kmsgrab ${D}${bindir}/kmsgrab
}
