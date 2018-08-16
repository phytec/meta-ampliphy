FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += "\
  file://grayxx.patch \
"
PACKAGECONFIG_append = " v4l2"
