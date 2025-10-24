SUMMARY = "Phytec's security example image"
DESCRIPTION = "Support for filesystem encryption and user roles"
LICENSE = "MIT"

inherit features_check
require recipes-images/images/phytec-headless-image.bb
require recipes-images/images/security/setrootpassword.inc

REQUIRED_DISTRO_FEATURES = "secureboot"

_FITIMAGE_TO_WIC = "\
    ${@bb.utils.contains('KERNEL_IMAGETYPES', 'fitImage', '', \
    '${@bb.utils.contains("MACHINE_FEATURES", "emmc", "phytec-secureboot-initramfs-fitimage:do_deploy", "phytec-simple-fitimage:do_deploy", d)}' \
    , d)}"

do_image[depends] += "\
    ${@bb.utils.contains('UBOOT_SIGN_ENABLE','1','${_FITIMAGE_TO_WIC}','', d)}"

IMAGE_INSTALL += " \
    ${@bb.utils.contains("DISTRO_FEATURES", "protectionshield", "phytec-example-users", "", d)} \
    rng-tools \
    packagegroup-sks-kernelkeyring \
    ${@bb.utils.contains("DISTRO_FEATURES", "virtualization", "packagegroup-virtualization", "", d)} \
"
