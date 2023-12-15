FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "\
    file://cryptodev-fix-build-for-linux-6.7-rc1.patch \
"
