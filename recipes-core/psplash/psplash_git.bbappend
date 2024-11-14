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

SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"
SPLASH_IMAGES:am57xx = "file://psplash-poky-small.png;outsuffix=default"
SPLASH_IMAGES:mx6-generic-bsp = "file://psplash-poky-small.png;outsuffix=default"
SPLASH_IMAGES:phyboard-segin-imx93 = "file://psplash-poky-small.png;outsuffix=default"

do_configure:prepend() {
    if echo "${SPLASH_IMAGES}" | grep -q "psplash-poky-small.png"; then
        cp ${UNPACKDIR}/psplash-poky-small.png  ${S}/base-images/psplash-poky.png
        cp ${UNPACKDIR}/psplash-bar-small.png  ${S}/base-images/psplash-bar.png
    else
        cp ${UNPACKDIR}/psplash-poky.png  ${S}/base-images
        cp ${UNPACKDIR}/psplash-bar.png  ${S}/base-images
    fi
}

