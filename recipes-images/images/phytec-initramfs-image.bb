SUMMARY = "Phytec initramfs image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
check for hardware problems or flash new software to the eMMC. \
The kernel includes the Minimal RAM-based Initial Root Filesystem \
(initramfs), which finds the first 'init' program more efficiently."
LICENSE = "MIT"

# Do not pollute the initrd image with rootfs features
IMAGE_LINGUAS = ""

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_OVERHEAD_FACTOR = "1.0"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"

export IMAGE_BASENAME = "phytec-initramfs-image"
IMAGE_NAME_SUFFIX ?= ""

IMAGE_FEATURES = " \
    allow-empty-password \
    allow-root-login \
    empty-root-password \
"

inherit core-image

PACKAGE_INSTALL = " \
    packagegroup-core-boot \
    systemd-initramfs \
    systemd-networkd \
    systemd-conf \
    openssh \
    busybox \
    packagegroup-hwtools-diagnostic \
    partup \
"

PACKAGE_EXCLUDE = "kernel-image-*"

NO_RECOMMENDATIONS = "1"
