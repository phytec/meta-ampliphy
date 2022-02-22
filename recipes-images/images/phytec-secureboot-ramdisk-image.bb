SUMMARY = "PHYTEC eMMC image for secure storage"
DESCRIPTION = "Mount the protected rootfs partitions for booting"
LICENSE = "MIT"
require recipes-images/images/security/phytec-security-base-ramdisk.inc

PACKAGE_INSTALL_append_securestorage = " secure-storage"

export IMAGE_BASENAME = "phytec-secureboot-ramdisk-image"
