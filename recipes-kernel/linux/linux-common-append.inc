inherit kernel-module-split-blacklist
inherit deselect-fragments
include recipes-kernel/linux/mtd_test_packages.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/features:"

SRC_URI_append = " file://mtd-tests.cfg"
KERNEL_MODULES_RDEPENDS_BLACKLIST += "${MTD_TEST_PACKAGES}"

SRC_URI_append_secureboot = " \
    file://fs_encryption.cfg \
    file://trustedkey-base.cfg \
    ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'file://trustedkey-tpm.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'caam', 'file://trustedkey-caam.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'file://trustedkey-tee.cfg', '', d)} \
"
SRC_URI_append_kernelmodsign = " \
    file://kernel-modsign.cfg \
"
SRC_URI_append_update = " \
    file://rauc.cfg \
"

SRC_URI_append_hardening = " \
    file://hardening.cfg \
    ${@contain_deselect('bluetooth', d)} \
    ${@contain_deselect('can', d)} \
    ${@contain_deselect('debug', d)} \
    ${@contain_deselect('kvm', d)} \
    ${@contain_deselect('media', d)} \
    ${@contain_deselect('optee', d)} \
    ${@contain_deselect('pci', d)} \
    ${@contain_deselect('wifi', d)} \
    ${@contain_deselect('xen', d)} \
"

inherit ${@bb.utils.contains('DISTRO_FEATURES', 'kernelmodsign', 'kernel-modsign', '', d)}

LOCALVERSION = "-${@legitimize_package_name(d.getVar('DISTRO_VERSION', True))}"
