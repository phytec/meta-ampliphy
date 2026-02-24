DESCRIPTION = "Userlandtools for gstreamer and cameras"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    gstreamer1.0 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-bad \
    gst-plugin-i2c \
"

# Camera tools by PHYTEC
RDEPENDS:${PN}:append:mx6-generic-bsp = " \
    phytec-camera-examples-imx6 \
    gstreamer1.0-plugin-vita1300-remapper \
"

RDEPENDS:${PN}:append:mx6ul-generic-bsp = " \
    phytec-camera-examples-imx6ul \
    gstreamer1.0-plugins-imx \
"

RDEPENDS:${PN}:append:mx7-nxp-bsp = " \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
"

RDEPENDS:${PN}:append:mx8mm-nxp-bsp = " \
    phytec-camera-examples-imx8mm \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
"

RDEPENDS:${PN}:append:mx8mp-nxp-bsp = " \
    phytec-camera-examples-imx8mp \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
"

RDEPENDS:${PN}:append:mx93-nxp-bsp = " \
    gstreamer1.0-plugin-bayer2rgb-neon \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
"

RDEPENDS:${PN}:append:mx95-nxp-bsp = " \
    gstreamer1.0-plugin-bayer2rgb-neon \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
    libcamera-gst \
"

RDEPENDS:${PN}:append:am57xx = " \
    gstreamer1.0-plugin-bayer2rgb-neon \
"

RDEPENDS:${PN}:append:j721s2 = " \
    gstreamer1.0-plugin-bayer2rgb-neon \
"
