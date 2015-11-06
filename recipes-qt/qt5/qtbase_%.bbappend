FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

# The string 'gl' is in PACKAGECONFIG because "opengl" is in yogurt's
# DISTRO_FEATURES. Since our boards only support egl/gles2 and not the full
# opengl, we have to disable gl and enable gles2 by hand here.
PACKAGECONFIG_remove = "gl"
PACKAGECONFIG_append_ti33x = " gles2"
PACKAGECONFIG_append_mx6 = " gles2"

DEPENDS_append = " tslib"

PACKAGECONFIG_MULTIMEDIA_append = " alsa"
PACKAGECONFIG_DEFAULT_append = " tslib"

QT_CONFIG_FLAGS_append = " -tslib -qreal float"

#this is necessary for qtquickcontrols-qmlplugins
PACKAGECONFIG_append = " accessibility"

#this is required by qtwebkit
PACKAGECONFIG_append = " icu"

#this is required by our demo application, qtwebkit cookie database
PACKAGECONFIG_append = " sql-sqlite"

SRC_URI_append = " file://0001-patch-for-evdevtouch-while-using-tslib-questions-reg.patch" 
SRC_URI_append = " file://res-touchscreen.rules"
SRC_URI_append = " file://qtLauncher"

# From the layer meta-fsl-arm. Fix qtbase build.
SRC_URI_append_mx6 = " file://Force_egl_visual_ID_33.patch"
do_configure_prepend_mx6() {
        # adapt qmake.conf to our needs
        sed -i 's!load(qt_config)!!' ${S}/mkspecs/linux-oe-g++/qmake.conf

        # copy the hook in the mkspecs directory OE is using
        cp ${S}/mkspecs/devices/linux-imx6-g++/qeglfshooks_imx6.cpp ${S}/mkspecs/linux-oe-g++/

        cat >> ${S}/mkspecs/linux-oe-g++/qmake.conf <<EOF
EGLFS_PLATFORM_HOOKS_SOURCES = \$\$PWD/qeglfshooks_imx6.cpp
IMX6_CFLAGS             = -DLINUX=1 -DEGL_API_FB=1
QMAKE_LIBS_EGL         += -lEGL
QMAKE_LIBS_OPENGL_ES2  += -lGLESv2 -lEGL -lGAL
QMAKE_LIBS_OPENVG      += -lOpenVG -lEGL -lGAL
QMAKE_CFLAGS_RELEASE   += \$\$IMX6_CFLAGS
QMAKE_CXXFLAGS_RELEASE += \$\$IMX6_CFLAGS
QMAKE_CFLAGS_DEBUG     += \$\$IMX6_CFLAGS
QMAKE_CXXFLAGS_DEBUG   += \$\$IMX6_CFLAGS

load(qt_config)

EOF
}

# Set default QT_QPA_PLATFORM for all phytec boards
do_configure_prepend() {
        # adapt qmake.conf to our needs
        sed -i 's!load(qt_config)!!' ${S}/mkspecs/linux-oe-g++/qmake.conf

        # Insert QT_QPA_PLATFORM into qmake.conf
        cat >> ${S}/mkspecs/linux-oe-g++/qmake.conf <<EOF

QT_QPA_DEFAULT_PLATFORM = eglfs

load(qt_config)

EOF
}

#skip QA tests for examples
INSANE_SKIP_${PN}-examples-dev += "libdir"
INSANE_SKIP_${PN}-examples-dbg += "libdir"

do_install_append () {
	install -d ${D}${nonarch_base_libdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/res-touchscreen.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}/usr/bin
	install -m 0755 ${WORKDIR}/qtLauncher ${D}/usr/bin/
}
