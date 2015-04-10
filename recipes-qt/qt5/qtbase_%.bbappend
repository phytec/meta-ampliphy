FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# The string 'gl' is in PACKAGECONFIG because "opengl" is in yogurt's
# DISTRO_FEATURES. Since our boards only support egl/gles2 and not the full
# opengl, we have to disable gl and enable gles2 by hand here.
PACKAGECONFIG_remove = "gl"
PACKAGECONFIG_append_ti33x = " gles2"

# The recipe libgles-omap3 doesn't install the package libgles2 and libegl by
# default, so we have to add explicit runtime dependences here. But these
# runtime dependences break the i.MX6 build, because they pull in the mesa
# recipe. For the gpu-viv-bin-mx6q recipe the build dependences to
# virtual/libegl and virtual/libgles2 are sufficient.
#
# Since PACKAGECONFIG doesn't supported machine overrides, we append these
# runtime dependences to the qtbase package directly.
RDEPENDS_${PN}_append_ti33x = " libgles2 libegl"

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
