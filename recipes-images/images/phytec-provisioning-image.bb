SUMMARY = "Phytec's provisioning example image"
DESCRIPTION = "is only for wic image building"
LICENSE = "MIT"
inherit image

PACKAGE_INSTALL = ""
LINGUAS_INSTALL = ""

do_image[depends] += "\
    ${@bb.utils.contains('KERNEL_IMAGETYPES', 'fitImage', '', 'phytec-provisioning-initramfs-fitimage:do_deploy', d)}"
