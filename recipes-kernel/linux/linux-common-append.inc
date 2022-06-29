inherit kernel-module-split-blacklist
inherit deselect-fragments
include recipes-kernel/linux/mtd_test_packages.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

SRC_URI:append = " file://mtd-tests.cfg"
KERNEL_MODULES_RDEPENDS_BLACKLIST += "${MTD_TEST_PACKAGES}"

SRC_URI:append:secureboot = " \
    file://fs_encryption.cfg \
    file://trustedkey-base.cfg \
    ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'file://trustedkey-tpm.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'caam', 'file://trustedkey-caam.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'file://trustedkey-tee.cfg', '', d)} \
"
SRC_URI:append:kernelmodsign = " \
    file://kernel-modsign.cfg \
"
SRC_URI:append:update = " \
    file://rauc.cfg \
"

SRC_URI:append:hardening = " \
    file://hardening.cfg \
    ${@create_deselection_list(['bluetooth', 'can', 'optee', 'pci', 'wifi'], d.getVar('KERNEL_FEATURES_DESELECT', True), d)} \
"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'kernelmodsign', 'kernel-modsign', '', d)}

LOCALVERSION = "-${@legitimize_package_name(d.getVar('DISTRO_VERSION'))}"
