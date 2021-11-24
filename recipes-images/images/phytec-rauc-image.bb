SUMMARY = "Phytec's headless image utilizing RAUC"
DESCRIPTION = "no graphics support in this image"
LICENSE = "MIT"
inherit core-image

IMAGE_ROOTFS_SIZE ?= "8192"

IMAGE_INSTALL = " \
    packagegroup-machine-base \
    packagegroup-core-boot \
    packagegroup-hwtools \
    packagegroup-userland \
    packagegroup-update \
    ${@bb.utils.contains("COMBINED_FEATURES", "alsa", "packagegroup-audio", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "wifi", "packagegroup-wifi", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "bluetooth", "packagegroup-bluetooth", "", d)} \
    ${@bb.utils.contains("COMBINED_FEATURES", "3g", "packagegroup-3g", "", d)} \
    tzdata \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-openssl-tpm2", "",  d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-provision-tpm2", "", d)} \
"

IMAGE_INSTALL:append:mx6 = " firmwared"
IMAGE_INSTALL:append:mx6ul = " firmwared"
IMAGE_INSTALL:append:mx8m = " firmwared"

WKS_FILES:mx6 = "imx6-rauc-sdimage.wks"
WKS_FILES:mx6ul = "imx6-rauc-sdimage.wks"
WKS_FILES:mx8m = "imx8m-rauc-sdimage.wks"
