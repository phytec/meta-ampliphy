# Copyright (C) 2016 PHYTEC Messtechnik GmbH,
# Author: Daniel Schultz <d.schultz@phytec.de>

DESCRIPTION = "This program flips one or more bits of a NAND partition"
LICENSE = "GPL-2.0-only"
SECTION = "devel"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

SRC_URI = "file://nandflipbits_wrapper"

PR = "r0"
S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

do_install() {
	install -d ${D}${sbindir}
	install -m 0755 nandflipbits_wrapper ${D}${sbindir}
}

RDEPENDS:${PN} = "mtd-utils"
FILES:${PN} = "${sbindir}"
