SUMMARY = "A KMS/DRM screenshot tool"
HOMEPAGE = "https://github.com/pcercuei/kmsgrab"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://kmsgrab.c;beginline=1;endline=6;md5=28a1f960814902f2eded43044c600387"

PV = "1.0"
PR = "r0"

BRANCH = "main"
SRC_URI = "git://github.com/pcercuei/kmsgrab.git;protocol=https;branch=${BRANCH}"
SRCREV = "d4c6061a59f4b7ecb6b39f96c7d39a5d5f48b702"

DEPENDS = "libdrm libpng"


inherit cmake pkgconfig

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/kmsgrab ${D}${bindir}/kmsgrab
}
