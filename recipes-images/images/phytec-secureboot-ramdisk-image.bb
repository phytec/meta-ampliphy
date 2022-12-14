SUMMARY = "PHYTEC eMMC image for secure storage"
DESCRIPTION = "Mount the protected rootfs partitions for booting"
LICENSE = "MIT"
require recipes-images/images/security/phytec-security-base-ramdisk.inc

IMAGE_INSTALL:append:securestorage = " secure-storage"

PACKAGE_EXCLUDE = "kernel-image-*"

export IMAGE_BASENAME = "phytec-secureboot-ramdisk-image"
