# Copyright (C) 2019 Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Small light functional Image for the main functionality"
LICENSE = "MIT"

inherit core-image image_types

IMAGE_ROOTFS_SIZE = "8192"
# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_FSTYPES = "cpio.gz"

include security/setrootpassword.inc

# Do not pollute the initrd image with rootfs features

PACKAGE_INSTALL = " \
    busybox \
    secureboot-fileencrypt \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-provision-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis-spi", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis", "", d)} \
    pv \
"

# Remove some packages added via recommendations
BAD_RECOMMENDATIONS += " \
    busybox-syslog \
"

export IMAGE_BASENAME = "phytec-secureboot-ramdisk-image"
