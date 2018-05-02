ACLOCAL_AMFLAGS = -I m4

AM_CFLAGS = \
	-Wall -W -Wno-unused-parameter \
	-Werror-implicit-function-declaration \
	${GST_CFLAGS}

AM_CPPFLAGS = \
	-D_GNU_SOURCE \
	-DPKG_DATADIR=\"${pkgdatadir}\"

AM_LDFLAGS = \
	-module -avoid-version -no-undefined

LIBTOOLFLAGS = \
	--tag=disable-static

plugin_LTLIBRARIES = \
	gstpseudocolor.la \
	gstpseudocolor2.la

pkgdata_DATA = \
	rainbow8.rgb \
	rainbow16.rgb

gstpseudocolor_la_SOURCES = \
	gstpseudocolor.c \
	gstpseudocolor.h

gstpseudocolor_la_LIBADD = \
	${GST_LIBS}

gstpseudocolor2_la_SOURCES = \
	gstpseudocolor2.c \
	gstpseudocolor2.h

gstpseudocolor2_la_LIBADD = \
	${GST_LIBS}

install-exec-hook:	.install-remove-libtool-crap
install-data-hook:	.install-remove-libtool-crap

.install-remove-libtool-crap:
	! cd '${DESTDIR}${plugindir}' || rm -f ${plugin_LTLIBRARIES}
