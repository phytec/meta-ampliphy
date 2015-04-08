FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

HAS_X11 = "${@base_contains('DISTRO_FEATURES', 'x11', 1, 0, d)}"

GLES2_X11_FLAG = "${@base_contains('DISTRO_FEATURES', 'x11', ' -no-eglfs', ' -eglfs', d)}"
PACKAGECONFIG[gles2] = "-opengl es2 ${GLES2_X11_FLAG},,virtual/libgles2 virtual/egl, libgles2 libegl"
PACKAGECONFIG_GL_ti33x = "gles2"

#this is necessary for qtquickcontrols-qmlplugins
PACKAGECONFIG_append = " accessibility"

#environment settings for qt5
SRC_URI += "file://qt_env.sh"

do_install_append () {
    install -d ${D}${sysconfdir}/profile.d
    install -m 0755 ${WORKDIR}/qt_env.sh ${D}${sysconfdir}/profile.d/
}

PACKAGES =+ "${PN}-conf"

FILES_${PN}-conf = "${sysconfdir}/profile.d/qt_env.sh"

RDEPENDS_${PN} += "${PN}-conf"

#skip QA tests for examples
INSANE_SKIP_${PN}-examples-dev += "libdir"
INSANE_SKIP_${PN}-examples-dbg += "libdir"
