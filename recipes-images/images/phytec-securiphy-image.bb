SUMMARY = "Phytec minimal security image"
DESCRIPTION = "Support for filesystem encryption"
LICENSE = "MIT"

inherit core-image
inherit features_check

REQUIRED_DISTRO_FEATURES = "secureboot"

_FITIMAGE_TO_WIC = "\
    ${@bb.utils.contains('KERNEL_IMAGETYPES', 'fitImage', '', \
    '${@bb.utils.contains("MACHINE_FEATURES", "emmc", "phytec-secureboot-initramfs-fitimage:do_deploy", "phytec-simple-fitimage:do_deploy", d)}' \
    , d)}"

do_image[depends] += "\
    ${@bb.utils.contains('UBOOT_SIGN_ENABLE','1','${_FITIMAGE_TO_WIC}','', d)}"

IMAGE_INSTALL = " \
    packagegroup-base \
    packagegroup-core-boot \
    packagegroup-cryptodev \
    openssh \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-openssl-tpm2", "",  d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "optee", "packagegroup-tee", "", d)} \
    packagegroup-sks-kernelkeyring \
"

IMAGE_INSTALL:append:mx6-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx6ul-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx8m-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx91-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx93-generic-bsp = " firmwared"
IMAGE_INSTALL:remove:am62lxx = " packagegroup-coprocessor"
