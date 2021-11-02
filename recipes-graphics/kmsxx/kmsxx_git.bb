SUMMARY = "C++ library for kernel mode setting"
HOMEPAGE = "https://github.com/tomba/kmsxx"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=815ca599c9df247a0c7f619bab123dad"

PV = "1.0"
PR = "r2"

BRANCH = "master"
SRC_URI = "gitsm://github.com/tomba/kmsxx.git;protocol=https;branch=${BRANCH}"
SRCREV = "b121eeaf11b28c7cecfeb533499abf05130816b4"

DEPENDS = "libdrm python3-pybind11 libevdev"

PACKAGES =+ "${PN}-python"

FILES_${PN}-python += "${libdir}/python*/site-packages"

S = "${WORKDIR}/git"

inherit python3native cmake update-alternatives

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/bin/kmsview ${D}${bindir}/kmsview
    install -m 755 ${B}/bin/kmstest ${D}${bindir}/kmstestscreen
    install -m 755 ${B}/bin/kmsblank ${D}${bindir}/kmsblank
}
