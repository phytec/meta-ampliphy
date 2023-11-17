SUMMARY = "Phytec's provisioning example image"
DESCRIPTION = "is only for wic image building"
LICENSE = "MIT"
inherit image

FITIMAGE_SIGN ??= "false"
FITIMAGE_SIGN[type] = "boolean"

PACKAGE_INSTALL = ""
LINGUAS_INSTALL = ""

do_image_wic[depends] += "\
    phytec-provisioning-initramfs-fitimage:do_deploy"
PARTUP_PACKAGE_DEPENDS:append = " phytec-provisioning-initramfs-fitimage"
