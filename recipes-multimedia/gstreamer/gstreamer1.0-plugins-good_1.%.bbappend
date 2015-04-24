FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += "\
  file://0001-Support-more-bayer-formats.patch \
  file://0002-Allow-to-access-v4l2-in-raw-mode.patch \
"
