inherit kernel-module-split-blacklist
include recipes-kernel/linux/mtd_test_packages.inc

FILESEXTRAPATHS_prepend := "${THISDIR}/features:"
SRC_URI_append = " file://mtd-tests.cfg"
KERNEL_MODULES_RDEPENDS_BLACKLIST += "${MTD_TEST_PACKAGES}"

LOCALVERSION = "-${DISTRO_VERSION}"
