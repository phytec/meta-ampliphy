FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += "\
  file://0001-Support-more-bayer-formats.patch \
  file://0002-Allow-to-access-v4l2-in-raw-mode.patch \
  file://0001-v4l2object-Update-formats-table.patch \
  file://0001-v4l2-Update-kernel-headers-to-latest-from-media-tree.patch \
"
