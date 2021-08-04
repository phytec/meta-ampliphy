FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "\
  file://grayxx.patch \
"
PACKAGECONFIG:append = " v4l2"
