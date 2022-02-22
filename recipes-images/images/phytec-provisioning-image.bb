SUMMARY = "Phytec's provisioning example image"
DESCRIPTION = "is only for wic image building"
LICENSE = "MIT"
inherit image

FITIMAGE_SIGN ??= "false"
FITIMAGE_SIGN[type] = "boolean"

do_image_wic[depends] += "\
    phytec-provisioning-ramdisk-fitimage:do_deploy"
