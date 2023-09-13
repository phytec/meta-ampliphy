FILESEXTRAPATHS:prepend := "${THISDIR}:"

SRC_URI:append = " \
    file://0001-psplash-Change-colors-to-PHYTEC-palette.patch \
    file://psplash-poky.png \
    file://psplash-bar.png \
"

SPLASH_IMAGES = "file://psplash-poky.png;outsuffix=default"

do_configure:prepend() {
    cp ${WORKDIR}/*.png ${S}/base-images
}

