# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Modified es2gears (known as glxgears) for i.MX6 framebuffer"
HOMEPAGE = "www.phytec.de"
SECTION = "extras"

# PV is 8.2.0 because the file was copied from mesa-demos version 8.2.0

LICENSE = "MIT"
LIC_FILES_CHKSUM = " \
    file://es2gears.c;beginline=4;endline=19;md5=178215d4cfeca51c0162f74ac3f7e68f \
    file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302 \
"

SRC_URI = "file://es2gears.c"

inherit pkgconfig

DEPENDS += "virtual/egl virtual/libgles2"

PR = "r3"

S = "${WORKDIR}"

do_compile () {
    ${CC} ${CFLAGS} ${LDFLAGS} -o ${B}/es2gears ${S}/es2gears.c -Wall \
        $(pkg-config --libs --cflags glesv2) \
        $(pkg-config --libs --cflags egl) \
	-lm
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/es2gears ${D}${bindir}/es2gears
}
