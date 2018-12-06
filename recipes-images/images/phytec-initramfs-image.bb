SUMMARY = "Phytec initramfs image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
check for hardware problems. The kernel includes \
the Minimal RAM-based Initial Root Filesystem (initramfs), which finds the \
first 'init' program more efficiently."

PACKAGE_INSTALL = "busybox-initramfs base-files base-passwd ${ROOTFS_BOOTSTRAP_INSTALL} \
  packagegroup-hwtools \
  iperf3 \
"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = "empty-root-password"

export IMAGE_BASENAME = "phytec-initramfs-image"
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

BAD_RECOMMENDATIONS += "busybox-syslog"
