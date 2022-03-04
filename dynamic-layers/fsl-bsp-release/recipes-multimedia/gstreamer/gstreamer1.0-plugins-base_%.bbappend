FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append:mx8m-generic-bsp = "\
  file://0001-Revert-disable-orc-build-for-gst-base-video.patch \
"
