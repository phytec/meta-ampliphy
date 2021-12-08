FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI_append_mx8m = "\
  file://0001-Revert-disable-orc-build-for-gst-base-video.patch \
  file://0001-allocators-dmabuf-Don-t-use-dmabuf-synchronization-o.patch \
"
