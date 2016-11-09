# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Wadim Egorov <w.egorov@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "This is a fork of extremetuxracer (http://extremetuxracer.com)\
focussing on cross-platform, performance & OpenGL-ES support."
HOMEPAGE = "http://extremetuxracer.com"
LICENSE = "GPLv2+"
LIC_FILES_CHKSUM = "file://main.cpp;beginline=1;endline=16;md5=0027c39c1fd4ac94c7efe6cbe2d4c1f8"

PR = "r1"

S = "${WORKDIR}/git"
PV = "1.0+git${SRCPV}"

SRC_URI = "git://github.com/meveric/extremetuxracer.git"
SRCREV = "ae1f98af55331ff8f6f4c057814670a74f83dcd5"

SRC_URI += " \
	file://0001-Add-EGL-framebuffer-initialization.patch \
	file://0002-Remove-CXXFLAGS-LDFLAGS-assignment.patch \
	file://0003-winsys-add-i.MX6-specific-stuff.patch \
"

EXTRA_OEMAKE += "GLES=1"

CXXFLAGS += "-DHAVE_GL_GLES1 -DEGL_API_FB -DOS_LINUX -I=/usr/include/freetype2 \
		$$(pkg-config --cflags glesv1_cm) \
		$$(pkg-config --cflags egl)"
LDFLAGS += " -lSDL -lSDL_image -lSDL_mixer -lfreetype \
		$$(pkg-config --libs glesv1_cm) \
		$$(pkg-config --libs egl)"

gamesdir="/usr/games"
do_install () {
	install -d ${D}${gamesdir}/etr/data
	cp -r data/* ${D}${gamesdir}/etr/data
	install -m 0755 ${S}/etr ${D}${gamesdir}/etr/etr
}

DEPENDS += " libpng libpng12 virtual/egl virtual/libgles1 virtual/libgles2 libsdl libsdl-image libsdl-mixer freetype freetype-native"

FILES_${PN} += " \
	${pkgdata} \
	${gamesdir}/etr \
	${gamesdir}/etr/data"
