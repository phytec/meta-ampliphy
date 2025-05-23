SUMMARY = "Phytec's headless image"
DESCRIPTION = "no graphics support in this image"
LICENSE = "MIT"
inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"

IMAGE_INSTALL = " \
    packagegroup-machine-base \
    packagegroup-core-boot \
    packagegroup-hwtools \
    packagegroup-benchmark \
    packagegroup-userland \
    packagegroup-userland-flashing \
    packagegroup-rt \
    packagegroup-coprocessor \
    packagegroup-cryptodev \
    ${@bb.utils.contains("COMBINED_FEATURES", "alsa", "packagegroup-audio", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "wifi", "packagegroup-wifi", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "bluetooth", "packagegroup-bluetooth", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "3g", "packagegroup-3g", "", d)} \
    tzdata \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-openssl-tpm2", "",  d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-provision-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "optee", "packagegroup-tee", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "camera", "packagegroup-camera", "",  d)} \
"

IMAGE_INSTALL:append:update = " packagegroup-update"

IMAGE_INSTALL:append:mx6-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx6ul-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx8m-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx91-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx93-generic-bsp = " firmwared"
IMAGE_INSTALL:remove:am62lxx = " packagegroup-coprocessor"
