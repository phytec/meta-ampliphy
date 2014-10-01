SUMMARY = "Yogurt"
DESCRIPTION = "An image to test directfb with Yocto."
LICENSE = "MIT"
IMAGE_LINGUAS = " "

inherit core-image distro_features_check

#build barebox too
IMAGE_RDEPENDS += "barebox barebox-ipl"

#this image uses egl driver a framebuffer hw accell driver
DISTRO_FEATURES_remove = "x11 wayland"
CONFLICT_DISTRO_FEATURES = "x11"
CONFLICT_DISTRO_FEATURES = "wayland"
REQUIRED_DISTRO_FEATURES = "directfb"

IMAGE_INSTALL = " \
    packagegroup-base \
    packagegroup-core-boot \
    packagegroup-core-directfb \
    directfb-examples \
    omapfbplay \
    devmem2 \
    tslib-conf \
    tslib-calibrate \
    tslib-tests \
"

export IMAGE_BASENAME = "yogurt-directfb"


