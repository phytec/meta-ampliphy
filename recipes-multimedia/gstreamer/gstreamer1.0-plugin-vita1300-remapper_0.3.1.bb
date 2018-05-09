SUMMARY = "Gstreamer pluging for VITA 1300 Sensor image data conversion"
DESCRIPTION = "Gstreamer plugin using the VITA 1300 Sensor image data conversion library"
SECTION = "multimedia"
HOMEPAGE = "https://git.phytec.de/gst-vita-1300-remapper/"

LICENSE = "GPLv2"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"

BRANCH = "master"
SRC_URI = "git://git.phytec.de/gst-vita-1300-remapper;branch=${BRANCH}"

S = "${WORKDIR}/git"

# NOTE: Keep sha1sum in sync with recipe version and git tag
SRCREV = "80871a43c811de45e4296e828bd4816c9932c18f"
PV = "0.3.1+git${SRCPV}"

PR = "r0"

inherit pkgconfig autotools

DEPENDS += "vita-1300-remapper gstreamer1.0-plugins-base gstreamer1.0"

FILES_${PN} += "${libdir}/gstreamer-*/*.so"
FILES_${PN}-dbg += "${libdir}/gstreamer-*/.debug"
