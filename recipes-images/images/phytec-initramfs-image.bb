SUMMARY = "Phytec initramfs image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
check for hardware problems or flash new software to the eMMC. \
The kernel includes the Minimal RAM-based Initial Root Filesystem \
(initramfs), which finds the first 'init' program more efficiently."

PACKAGE_INSTALL = " \
    packagegroup-core-boot \
    packagegroup-core-ssh-openssh \
    packagegroup-base \
    packagegroup-hwtools-diagnostic \
    partup \
"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = " \
    allow-empty-password \
    allow-root-login \
    empty-root-password \
"

# Don't allow the initramfs to contain a kernel
PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
IMAGE_FSTYPES:update = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

export IMAGE_BASENAME = "phytec-initramfs-image"
NO_RECOMMENDATIONS = "1"
