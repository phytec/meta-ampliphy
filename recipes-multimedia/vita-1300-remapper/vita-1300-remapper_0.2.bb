SUMMARY = "VITA 1300 Sensor image data conversion"
DESCRIPTION = "VITA 1300 Sensor image data conversion"
SECTION = "libs"
HOMEPAGE = "https://git.phytec.de/vita-1300-remapper/"

LICENSE = "LGPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=e6a600fd5e1d9cbde2d983680233ad02"

BRANCH = "master"
SRC_URI = "git://git.phytec.de/${BPN};branch=${BRANCH}"

S = "${WORKDIR}/git"

# NOTE: Keep sha1sum in sync with recipe version and git tag
SRCREV = "e379b40458d221e7c735b68b1fea79c91f3cb958"
PV = "0.2+git${SRCPV}"

inherit autotools ptest pkgconfig lib_package

PACKAGES =+ "${PN}-test"
FILES_${PN}-dbg += "${libdir}/vita-1300_remapper/.debug"
FILES_${PN}-test += "${libdir}/vita-1300_remapper"
