# Copyright (C) 2016 PHYTEC Messtechnik GmbH,
# Author: Daniel Schultz <d.schultz@phytec.de>

DESCRIPTION = "This program flips one or more bits of a NAND partition"
LICENSE = "GPL-2.0"
SECTION = "devel"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://nandflipbits.c \
	   file://nandflipbits_wrapper"

PR = "r0"
S = "${WORKDIR}"

DEPENDS = "mtd-utils"

do_compile() {
	${CC} ${CFLAGS} ${LDFLAGS} -o nandflipbits nandflipbits.c -lmtd
}

do_install() {
	install -d ${D}${bindir}
	install -m 0755 nandflipbits ${D}${bindir}
	install -m 0755 nandflipbits_wrapper ${D}${bindir}
}

FILES_${PN} = "${bindir}"
