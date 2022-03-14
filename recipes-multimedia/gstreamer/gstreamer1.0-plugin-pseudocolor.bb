SUMMARY = "gstreamer pseudocolor plugin"
SECTION = "multimedia"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0-only;md5=801f80980d171dd6425610833a22dbe6"

BRANCH = "master"

PR = "r0"

SOURCES = "\
  Makefile.am \
  configure.ac \
  gstpseudocolor.c \
  gstpseudocolor.h \
  gstpseudocolor2.c \
  gstpseudocolor2.h \
  rainbow8.rgb \
  rainbow16.rgb \
"

SRC_URI[vardeps] += "SOURCES"
SRC_URI = "\
  ${@' '.join(map(lambda x: 'file://%s;subdir=src' % x, \
                  d.getVar('SOURCES', False).split()))} \
"

S = "${WORKDIR}/src"

inherit pkgconfig autotools

DEPENDS += "gstreamer1.0-plugins-base gstreamer1.0"

FILES:${PN} += "\
  ${libdir}/gstreamer-*/*.so \
  ${datadir}/gstpseudocolor/ \
"

FILES:${PN}-dbg += "${libdir}/gstreamer-*/.debug"
