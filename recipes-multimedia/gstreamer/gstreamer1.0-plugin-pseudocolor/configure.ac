#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

AC_PREREQ([2.69])
AC_INIT([gstpseudocolor],[0.1],[Matthias Rabe <matthias.rabe@sigma-chemnitz.de>])
AM_INIT_AUTOMAKE([foreign subdir-objects])
AM_MAINTAINER_MODE

AC_CONFIG_SRCDIR([gstpseudocolor.c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_MACRO_DIR([m4])

dnl check for tools (compiler etc.)
AC_PROG_CC
LT_INIT

dnl required versions of gstreamer and plugins-base
GST_REQUIRED=1.6

PKG_CHECK_MODULES([GST], [
  gstreamer-1.0 >= $GST_REQUIRED
  gstreamer-base-1.0 >= $GST_REQUIRED
  gstreamer-controller-1.0 >= $GST_REQUIRED
  gstreamer-video-1.0 >= $GST_REQUIRED
], [
  AC_SUBST(GST_CFLAGS)
  AC_SUBST(GST_LIBS)
], [
  AC_MSG_ERROR([gstreamer libs missing])
])

m4_pattern_allow([PKG_CHECK_VAR])
m4_ifndef([PKG_CHECK_VAR],[
	m4_define([broken_PKG_CHECK_VAR])
	m4_define([PKG_CHECK_VAR],[])
])

AC_MSG_CHECKING([for plugindir])
AC_ARG_WITH([plugindir],
	[AS_HELP_STRING([--with-plugindir],
	 [gstreamer plugin directory @<:@default=check@:>@])],
	[plugindir=$withval],
	[
		PKG_CHECK_VAR([plugindir], [gstreamer-1.0], [pluginsdir])
		m4_ifdef([broken_PKG_CHECK_VAR],
			[AC_MSG_WARN([PKG_CHECK_VAR not available; will guess pluginsdir])
			 plugindir=${libdir}/gstreamer-1.0
			 AC_SUBST(plugindir)])
])
AC_MSG_RESULT([$plugindir])

AC_CONFIG_FILES([Makefile])
AC_CONFIG_COMMANDS([libtool-fixup],
	[sed -i -e 's!\$CC -shared!\0 -Wl,-as-needed!g' libtool; false])
AC_OUTPUT
