SUMMARY = "Phytec's security example image"
DESCRIPTION = "Support for filesystem encryption and user roles"
LICENSE = "MIT"

require recipes-images/images/phytec-headless-image.bb
require recipes-images/images/security/setrootpassword.inc
require recipes-images/images/security/phytec-pkcs11-tools.inc

_XTRA_SETUP = "${@bb.utils.contains("MACHINE_FEATURES", "emmc", "ramdisk-fitimage", "simple-fitimage", d)}"
require recipes-images/images/security/${_XTRA_SETUP}.inc

IMAGE_INSTALL += " \
    ${@bb.utils.contains("DISTRO_FEATURES", "protectionshield", "phytec-example-users", "", d)} \
    rng-tools \
    packagegroup-sks-kernelkeyring \
"
