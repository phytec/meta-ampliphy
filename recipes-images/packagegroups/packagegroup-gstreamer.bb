# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

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
    gstreamer1.0-plugins-bad-kmssink \
    gstreamer1.0-plugins-bad-fbdevsink \
    gstreamer1.0-plugins-bad-videoparsersbad \
    gst-plugin-i2c \
"

# Camera tools by PHYTEC
RDEPENDS_${PN}_append_mx6 = " \
    phytec-gstreamer-examples \
    bvtest \
    phytec-v4l2-c-examples \
"
