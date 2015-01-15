# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Userlandtools for gstreamer"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    gstreamer \
    gst-plugins-base-videoscale \
    gst-plugins-base-ffmpegcolorspace \
    gst-plugins-good-video4linux2 \
    gst-plugins-bad-bayer \
    gst-plugins-bad-fbdevsink \
    v4l-utils \
"

