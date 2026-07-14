SUMMARY = "Phytec minimal security image"
DESCRIPTION = "Support for filesystem encryption"
LICENSE = "MIT"

inherit core-image
inherit features_check

REQUIRED_DISTRO_FEATURES = "secureboot"

# Only i.MX6/i.MX6UL still build the FIT via the meta-ampliphy fitimage class;
# stage its do_deploy before do_image so wic can place fitImage in /boot.
_FITIMAGE_SEL = "${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'phytec-secureboot-initramfs-fitimage:do_deploy', 'phytec-simple-fitimage:do_deploy', d)}"
_PROV_FITIMAGE_DEP = ""
_PROV_FITIMAGE_DEP:mx6-generic-bsp   = "${_FITIMAGE_SEL}"
_PROV_FITIMAGE_DEP:mx6ul-generic-bsp = "${_FITIMAGE_SEL}"

do_image[depends] += "${_PROV_FITIMAGE_DEP}"

IMAGE_INSTALL = " \
    packagegroup-base \
    packagegroup-core-boot \
    packagegroup-cryptodev \
    openssh \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-openssl-tpm2", "",  d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "optee", "packagegroup-tee", "", d)} \
    packagegroup-sks-kernelkeyring \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "libdevmapper", "", d)} \
"

IMAGE_INSTALL:append:mx6-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx6ul-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx8m-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx91-generic-bsp = " firmwared"
IMAGE_INSTALL:append:mx93-generic-bsp = " firmwared"
