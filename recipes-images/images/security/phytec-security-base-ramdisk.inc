SUMMARY = "Security ramdisk base"
LICENSE = "MIT"

inherit core-image image_types

IMAGE_ROOTFS_SIZE = "8192"
# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "cpio.gz"

require setrootpassword.inc

IMAGE_INSTALL = " \
    busybox \
    ${MACHINE_EXTRA_RDEPENDS} \
    packagegroup-sks-kernelkeyring \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "packagegroup-secure-storage", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis-spi", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis", "", d)} \
    pv \
"
IMAGE_INSTALL:append:mx8m-generic-bsp = " ${MACHINE_FIRMWARE} kernel-module-imx-sdma"

# Remove some packages added via recommendations
BAD_RECOMMENDATIONS += " \
    busybox-syslog \
"
