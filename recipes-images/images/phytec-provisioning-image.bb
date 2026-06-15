SUMMARY = "Phytec's provisioning example image"
DESCRIPTION = "is only for wic image building"
LICENSE = "MIT"
inherit image

PACKAGE_INSTALL = ""
LINGUAS_INSTALL = ""

# Only i.MX6/i.MX6UL still build the FIT via the meta-ampliphy fitimage class;
# stage its do_deploy before do_image so wic can place fitImage in /boot.
_PROV_FITIMAGE_DEP = ""
_PROV_FITIMAGE_DEP:mx6-generic-bsp   = "phytec-provisioning-initramfs-fitimage:do_deploy"
_PROV_FITIMAGE_DEP:mx6ul-generic-bsp = "phytec-provisioning-initramfs-fitimage:do_deploy"

do_image[depends] += "${_PROV_FITIMAGE_DEP}"
