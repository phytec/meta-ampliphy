inherit kernel-module-split-blacklist
include recipes-kernel/linux/mtd_test_packages.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/features:"
SRC_URI_append = " file://mtd-tests.cfg file://rauc.cfg"
KERNEL_MODULES_RDEPENDS_BLACKLIST += "${MTD_TEST_PACKAGES}"

SRC_URI_append_secureboot = " \
    file://activated_securekeys.cfg \
    file://cryptodev_init.cfg \
    file://ext4_encryption.cfg \
    file://ubifs_encryption.cfg \
    file://dm_crypt_devicemapper.cfg \
    file://crypto-api.cfg \
"

LOCALVERSION = "-${@legitimize_package_name(d.getVar('DISTRO_VERSION', True))}"
