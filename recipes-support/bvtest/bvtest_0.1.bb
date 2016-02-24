# Copyright (C) 2016 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Camera test program from PHYTEC"
SECTION = "extras"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=a662ae2ca7498feb1c64188c76ea6f0e"

BRANCH = "master"
SRC_URI = "git://git.phytec.de/${PN};branch=${BRANCH};protocol=git"

S = "${WORKDIR}/git"

# NOTE: Keep sha1sum in sync with recipe version and git tag
SRCREV = "4201fc33741d8de38edb07a75d12ac85b1004f6f"
PV = "0.1+git${SRCPV}"

PR = "r0"

inherit autotools

DEPENDS += "libmikmod"
DEPENDS += "libv4l"
