# Copyright (C) 2015 PHYTEC Messtechnik GmbH
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "I2C GStreamer plug-in"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

SECTION = "multimedia"
DEPENDS += "gstreamer1.0 gstreamer1.0-plugins-base"

PR = "r1"

SRC_URI = "git://git.phytec.de/gst-plugin-i2c;branch=master"
SRCREV = "89eeee83a120a954f4b718918dccde1c6fab2de2"
PV = "1.1.0+git${SRCPV}"
S = "${WORKDIR}/git"

inherit autotools pkgconfig

FILES:${PN} += "${libdir}/gstreamer-1.0/*.so"
FILES:${PN}-dbg += "${libdir}/gstreamer-1.0/.debug"
FILES:${PN}-dev += "${libdir}/gstreamer-1.0/*.la"
