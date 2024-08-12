SUMMARY = "Phytec's security example image"
DESCRIPTION = "Support for filesystem encryption and user roles"
LICENSE = "MIT"

require recipes-images/images/phytec-headless-image.bb
require recipes-images/images/security/setrootpassword.inc

FITIMAGE_SIGN ??= "false"
FITIMAGE_SIGN[type] = "boolean"

_FITIMAGE_TO_WIC = ""
_FITIMAGE_TO_WIC:secureboot = "\
    ${@bb.utils.contains('KERNEL_IMAGETYPES', 'fitImage', '', \
    '${@bb.utils.contains("MACHINE_FEATURES", "emmc", "phytec-secureboot-initramfs-fitimage:do_deploy", "phytec-simple-fitimage:do_deploy", d)}' \
    , d)}"

do_image[depends] += "\
    ${@bb.utils.contains('FITIMAGE_SIGN','true','${_FITIMAGE_TO_WIC}','', d)}"

IMAGE_INSTALL += " \
    ${@bb.utils.contains("DISTRO_FEATURES", "protectionshield", "phytec-example-users", "", d)} \
    rng-tools \
    packagegroup-sks-kernelkeyring \
"
