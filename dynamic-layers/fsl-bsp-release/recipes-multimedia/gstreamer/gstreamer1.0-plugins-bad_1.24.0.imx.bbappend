FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-opencv-resolve-missing-opencv-data-dir-in-yocto-buil.patch \
"
