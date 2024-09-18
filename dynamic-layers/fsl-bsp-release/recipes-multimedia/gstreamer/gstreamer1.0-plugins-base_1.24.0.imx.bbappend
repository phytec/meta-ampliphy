FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI += "\
  file://0001-gst-libs-gstdmabufheaps-Use-uncached-cma-memory.patch \
  file://0001-Revert-disable-orc-build-for-gst-base-video.patch \
"
