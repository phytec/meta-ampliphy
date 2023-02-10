DESCRIPTION = "Userlandtools for gstreamer and cameras"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    media-ctl \
    v4l-utils \
    gstreamer1.0 \
    gstreamer1.0-libav \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-base-tcp \
    gstreamer1.0-plugins-base-pango \
    gstreamer1.0-plugins-base-videorate \
    gstreamer1.0-plugins-base-videoscale \
    gstreamer1.0-plugins-base-videoconvert \
    gstreamer1.0-plugins-good \
    gstreamer1.0-plugins-good-jpeg \
    gstreamer1.0-plugins-good-isomp4 \
    gstreamer1.0-plugins-good-multifile \
    gstreamer1.0-plugins-good-video4linux2 \
    gstreamer1.0-plugins-bad-bayer \
    gstreamer1.0-plugins-bad-fbdevsink \
    gstreamer1.0-plugins-bad-videoparsersbad \
    gstreamer1.0-plugins-bad-kms \
    gst-plugin-i2c \
"

# Camera tools by PHYTEC
RDEPENDS_${PN}_append_mx6 = " \
    phytec-camera-examples-imx6 \
    gstreamer1.0-plugin-vita1300-remapper \
    gstreamer1.0-plugins-bad-geometrictransform \
    gstreamer1.0-plugins-bad-zbar \
"

RDEPENDS_${PN}_append_mx6ul = " \
    phytec-gstreamer-examples-imx6ul \
    phytec-v4l2-c-examples-imx6ul \
    gstreamer1.0-plugins-bad-geometrictransform \
    gstreamer1.0-plugins-bad-zbar \
"

RDEPENDS_${PN}_append_mx8mq = " \
    phytec-camera-examples-imx8mq \
    gstreamer1.0-plugins-bad-geometrictransform \
    gstreamer1.0-plugins-bad-zbar \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
    gstreamer1.0-plugins-bad \
"

RDEPENDS_${PN}_append_mx8mm = " \
    phytec-camera-examples-imx8mm \
    gstreamer1.0-plugins-bad-geometrictransform \
    gstreamer1.0-plugins-bad-zbar \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
    gstreamer1.0-plugins-bad \
"

RDEPENDS_${PN}_append_mx8mp = " \
    phytec-camera-examples-imx8mp \
    gstreamer1.0-plugins-bad-geometrictransform \
    gstreamer1.0-plugins-bad-zbar \
    imx-gst1.0-plugin-gplay \
    imx-gst1.0-plugin \
    gstreamer1.0-plugins-bad \
"
