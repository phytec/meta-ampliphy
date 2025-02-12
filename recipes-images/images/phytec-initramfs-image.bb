SUMMARY = "Phytec initramfs image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
check for hardware problems or flash new software to the eMMC. \
The kernel includes the Minimal RAM-based Initial Root Filesystem \
(initramfs), which finds the first 'init' program more efficiently."

INITRAMFS_SCRIPTS ?= " \
    initramfs-framework-base \
    initramfs-module-udev \
    initramfs-module-network \
    initramfs-module-exec \
"

PACKAGE_INSTALL = " \
    ${INITRAMFS_SCRIPTS} \
    ${VIRTUAL-RUNTIME_base-utils} \
    ${VIRTUAL-RUNTIME_login_manager} \
    udev \
    bash \
    base-passwd \
    ${ROOTFS_BOOTSTRAP_INSTALL} \
    packagegroup-hwtools-diagnostic \
    partup \
"

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = "empty-root-password"

# Don't allow the initramfs to contain a kernel
PACKAGE_EXCLUDE = "kernel-image-*"

IMAGE_NAME_SUFFIX ?= ""
IMAGE_LINGUAS = ""

LICENSE = "MIT"

IMAGE_FSTYPES = "${INITRAMFS_FSTYPES}"
inherit core-image

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

export IMAGE_BASENAME = "phytec-initramfs-image"
BAD_RECOMMENDATIONS += " \
    initramfs-module-rootfs \
    busybox-syslog \
"
