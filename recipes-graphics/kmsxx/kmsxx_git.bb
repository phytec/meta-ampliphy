SUMMARY = "C++ library for kernel mode setting"
HOMEPAGE = "https://github.com/tomba/kmsxx"
LICENSE = "MPL-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=815ca599c9df247a0c7f619bab123dad"

PV = "1.0"
PR = "r2"

BRANCH = "master"
SRC_URI = "gitsm://github.com/tomba/kmsxx.git;protocol=https;branch=${BRANCH}"
SRCREV = "8cf1bdb791f008b0728a0de37e1f1b6648521ac2"

DEPENDS = "libdrm python3-pybind11 libevdev fmt"

PACKAGES =+ "${PN}-python"

FILES:${PN}-python += "${libdir}/python*/site-packages"

S = "${WORKDIR}/git"

inherit python3native meson update-alternatives pkgconfig

do_install() {
    install -d ${D}${libdir}
    install -m 0644 ${B}/kms++/libkms++.so.0 ${D}${libdir}
    install -m 0644 ${B}/kms++util/libkms++util.so.0 ${D}${libdir}

    install -d ${D}${bindir}
    install -m 755 ${B}/utils/kmsview ${D}${bindir}/kmsview
    install -m 755 ${B}/utils/kmstest ${D}${bindir}/kmstestscreen
    install -m 755 ${B}/utils/kmsblank ${D}${bindir}/kmsblank
}
