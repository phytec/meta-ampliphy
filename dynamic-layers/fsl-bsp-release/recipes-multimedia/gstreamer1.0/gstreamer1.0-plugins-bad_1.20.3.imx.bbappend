FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += " \
    file://0001-BACKPORT-opencv-Allow-building-against-4.6.x.patch \
"
