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

DEPENDS += "gpu-viv-bin-mx6q"

SRC_URI = "file://cldemo.c"
SRC_URI[md5sum] = "06c9df8712bfb78013ae306cc8bfd5de"
SRC_URI[sha256sum] = "ca415096d0219997de5aeb5df5e08cef75cff3f6f43da56dae2bf2ed6cd965a7"

PR = "r0"

do_unpack_append () {
    import shutil
    shutil.copy("${WORKDIR}/cldemo.c", "${S}")
}

do_compile () {
    # "-Wl,--no-as-needed" fixes the linker error:
    #    usr/lib/libOpenCL.so: undefined reference to `dlopen'
    #    usr/lib/libOpenCL.so: undefined reference to `dlclose'
    #    usr/lib/libOpenCL.so: undefined reference to `dlsym'
    ${CC} ${CFLAGS} ${LDFLAGS} -Wl,--no-as-needed -o ${B}/cldemo ${S}/cldemo.c \
        -std=gnu99 -Wall -lOpenCL -ldl
}

do_install() {
    install -d ${D}${bindir}
    install -m 744 ${B}/cldemo ${D}${bindir}/cldemo
}

RDEPENDS_${PN} += "libopencl-mx6"

COMPATIBLE_MACHINE = "mx6"
