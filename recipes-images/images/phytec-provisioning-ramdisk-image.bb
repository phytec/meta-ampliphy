SUMMARY = "PHYTEC Provisioning ramdisk image"
DESCRIPTION = "Boot from sd-card to install your image and file encryption on to board"
LICENSE = "MIT"
require recipes-images/images/security/phytec-security-base-ramdisk.inc
require recipes-images/images/security/phytec-tpm2-device.inc

IMAGE_INSTALL:append = " \
    packagegroup-hwtools \
    phyprovisoning-emmc \
    provisioning-init \
    physecurekeystorage-install \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "physecurestorage-install", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-provision-tpm2", "", d)} \
    rng-tools \
"

export IMAGE_BASENAME = "phytec-provisioning-ramdisk-image"
