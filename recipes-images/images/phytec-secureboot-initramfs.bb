SUMMARY = "PHYTEC eMMC image for secure storage"
DESCRIPTION = "Mount the protected rootfs partitions for booting"
LICENSE = "MIT"

inherit core-image image_types
require recipes-images/images/security/setrootpassword.inc

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"

IMAGE_FSTYPES = "cpio.gz"
export IMAGE_BASENAME = "phytec-secureboot-initramfs"

IMAGE_INSTALL = " \
    initramfs-framework-base \
    initramfs-module-udev \
    initramfs-module-securestorage \
    busybox \
    ${MACHINE_EXTRA_RDEPENDS} \
    packagegroup-sks-kernelkeyring \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "packagegroup-secure-storage", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis-spi", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis", "", d)} \
    pv \
"

IMAGE_INSTALL:append:mx8m-generic-bsp = " ${MACHINE_FIRMWARE} kernel-module-imx-sdma"

PACKAGE_EXCLUDE = "kernel-image-*"

# Remove some packages added via recommendations
BAD_RECOMMENDATIONS += " \
    initramfs-module-rootfs \
    initramfs-module-finish \
    busybox-syslog \
"
