SUMMARY = "Phytec's headless image"
DESCRIPTION = "no graphics support in this image"
LICENSE = "MIT"
inherit core-image

require security/setrootpassword.inc
include security/simple-fitimage.inc

IMAGE_ROOTFS_SIZE ?= "8192"

IMAGE_INSTALL = " \
    packagegroup-machine-base \
    packagegroup-core-boot \
    packagegroup-hwtools \
    packagegroup-benchmark \
    packagegroup-update \
    packagegroup-userland \
    packagegroup-rt \
    ${@bb.utils.contains("COMBINED_FEATURES", "alsa", "packagegroup-audio", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "wifi", "packagegroup-wifi", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "bluetooth", "packagegroup-bluetooth", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "3g", "packagegroup-3g", "", d)} \
    tzdata \
    ${@bb.utils.contains("DISTRO_FEATURES", "protectionshield", "phytec-example-users", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-openssl-tpm2", "",  d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-provision-tpm2", "", d)} \
"

IMAGE_INSTALL_append_mx6 = " firmwared"
IMAGE_INSTALL_append_mx6ul = " firmwared"
