# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Modified drmgears (known as glxgears) using the drm/gbm libraries"
HOMEPAGE = "www.phytec.de"
SECTION = "extras"

# PV is 8.2.0 because the file was copied from mesa-demos version 8.2.0

LICENSE = "MIT"
LIC_FILES_CHKSUM = " \
    file://drmgears.c;beginline=4;endline=19;md5=178215d4cfeca51c0162f74ac3f7e68f \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "file://drmgears.c"

inherit pkgconfig

DEPENDS += "libgbm libdrm virtual/egl virtual/libgles2"

PR = "r3"

S = "${WORKDIR}"

do_compile () {
    ${CC} ${CFLAGS} ${LDFLAGS} -o ${B}/drmgears ${S}/drmgears.c -Wall \
        $(pkg-config --libs --cflags glesv2) \
        $(pkg-config --libs --cflags libdrm) \
        $(pkg-config --libs --cflags gbm) \
        $(pkg-config --libs --cflags egl) \
	-lm
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/drmgears ${D}${bindir}/drmgears
}

COMPATIBLE_MACHINE = "rk3288"
