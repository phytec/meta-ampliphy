inherit kernel-module-split-disable
inherit deselect-fragments
include recipes-kernel/linux/mtd_test_packages.inc

FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

SRC_URI:append = " file://mtd-tests.cfg"
KERNEL_MODULES_RDEPENDS_DISABLE += "${MTD_TEST_PACKAGES}"

SRC_URI:append:kernelmodsign = " \
    file://kernel-modsign.cfg \
"
SRC_URI:append:update = " \
    file://rauc.scc \
"

SRC_URI:append:preempt-rt = " \
    file://rtla.scc \
"

KERNEL_FEATURES:append:update = " rauc.scc"
KERNEL_FEATURES:append:preempt-rt = " rtla.scc"

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
