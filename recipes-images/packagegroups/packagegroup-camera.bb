DESCRIPTION = "Userlandtools for cameras"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    media-ctl \
    v4l-utils \
    yavta \
    bvtest \
    bayer2rgb-neon-bin \
"
