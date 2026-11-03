inherit kernel-module-split-disable
inherit deselect-fragments
include recipes-kernel/linux/mtd_test_packages.inc
require ${@bb.utils.contains('DISTRO_FEATURES', 'rauc', 'recipes-kernel/linux/linux-yocto_rauc.inc', '', d)}

FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

SRC_URI:append = " file://mtd-tests.cfg"
KERNEL_MODULES_RDEPENDS_DISABLE += "${MTD_TEST_PACKAGES}"

SRC_URI:append:kernelmodsign = " \
    file://kernel-modsign.cfg \
"

SRC_URI:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', 'file://rtla.scc', '', d)}"
KERNEL_FEATURES:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', 'rtla.scc', '', d)}"

SRC_URI:append:hardening = " \
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
require ${@bb.utils.contains('DISTRO_FEATURES', 'secureboot', 'recipes-kernel/linux/secureboot.inc', '', d)}
