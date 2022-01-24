FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_append_mx8m = "\
  file://0001-Revert-disable-orc-build-for-gst-base-video.patch \
  file://0001-Revert-MMFMWK-8918-dmabufheaps-enable-dmabuf-heaps-m.patch \
  file://0002-Revert-MMFMWK-8918-dmabufheaps-enable-dmabuf-heaps-m.patch \
"
