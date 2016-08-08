# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

# cldemo.c is copied from http://svn.clifford.at/tools/trunk/examples/cldemo.c
# All kudos go to Clifford Wolf <clifford@clifford.at>

DESCRIPTION = "Simple OpenCL Demo Program"
HOMEPAGE = "http://svn.clifford.at/tools/trunk/examples/"
SECTION = "extras"

LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://cldemo.c;beginline=4;endline=18;md5=00379499873043e963fbafe29a874c64"

DEPENDS += "virtual/opencl"

SRC_URI = "file://cldemo.c"

PR = "r4"

S = "${WORKDIR}"

do_compile () {
    ${CC} ${CFLAGS} -std=gnu99 -Wall ${LDFLAGS} \
        -o ${B}/cldemo ${S}/cldemo.c \
        -lOpenCL
}

do_install() {
    install -d ${D}${bindir}
    install -m 755 ${B}/cldemo ${D}${bindir}/cldemo
}

RDEPENDS_${PN} += "libopencl"
