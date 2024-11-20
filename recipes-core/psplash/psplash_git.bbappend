FILESEXTRAPATHS:prepend := "${THISDIR}:"

SRC_URI:append = " \
    file://0001-psplash-Change-colors-to-PHYTEC-palette.patch \
    file://psplash-poky.png \
    file://psplash-bar.png \
    file://psplash-poky-small.png \
    file://psplash-bar-small.png \
"

SRC_URI:append:j721s2 = " \
    file://psplash-start.service  \
"

# psplash PHYTEC logo and progress bar are optimized for 720p & 1080p screen
# resolutions. However, lots of boards use screens with lower resolutions and
# in such case, logo does not fit the screen anymore and one must use smaller
# variants. To use smaller variants one can override SPLASH_IMAGES variable
# like so:
#
#  SPLASH_IMAGES:override = "file://psplash-poky-small.png;outsuffix=default"
#
SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"
SPLASH_IMAGES:am57xx = "file://psplash-poky-small.png;outsuffix=default"
SPLASH_IMAGES:mx6-generic-bsp = "file://psplash-poky-small.png;outsuffix=default"
SPLASH_IMAGES:phyboard-segin-imx93 = "file://psplash-poky-small.png;outsuffix=default"

do_configure:prepend() {
    if echo "${SPLASH_IMAGES}" | grep -q "psplash-poky-small.png"; then
        cp ${WORKDIR}/psplash-poky-small.png  ${S}/base-images/psplash-poky.png
        cp ${WORKDIR}/psplash-bar-small.png  ${S}/base-images/psplash-bar.png
    else
        cp ${WORKDIR}/psplash-poky.png  ${S}/base-images
        cp ${WORKDIR}/psplash-bar.png  ${S}/base-images
    fi
}

