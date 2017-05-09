FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RDEPENDS_${PN}_append = " tslib-conf tslib-calibrate"

PACKAGECONFIG_MULTIMEDIA_append = " alsa"
PACKAGECONFIG_DEFAULT_append = " tslib"

PACKAGECONFIG_FONTS = "fontconfig"

#this is necessary for qtquickcontrols-qmlplugins
PACKAGECONFIG_append = " accessibility"

#this is required by qtwebkit
PACKAGECONFIG_append = " icu"

#this is required by our demo application, qtwebkit cookie database
PACKAGECONFIG_append = " sql-sqlite"

#fix for 5.5
PACKAGECONFIG_append = " pcre"

#input devices
PACKAGECONFIG_append = " libinput xkbcommon-evdev"
PACKAGECONFIG_DEFAULT = "dbus udev widgets tools libs"

SRC_URI_append = " file://res-touchscreen.rules"
SRC_URI_append = " file://qtLauncher"

QT_QPA_DEFAULT_PLATFORM ??= "eglfs"

# Set default QT_QPA_PLATFORM for all phytec boards
do_configure_prepend() {
        # adapt qmake.conf to our needs
        sed -i 's!load(qt_config)!!' ${S}/mkspecs/linux-oe-g++/qmake.conf

        # Insert QT_QPA_PLATFORM into qmake.conf
        cat >> ${S}/mkspecs/linux-oe-g++/qmake.conf <<EOF

QT_QPA_DEFAULT_PLATFORM = ${QT_QPA_DEFAULT_PLATFORM}

load(qt_config)

EOF
}

do_install_append () {
	install -d ${D}${nonarch_base_libdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/res-touchscreen.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}/usr/bin
	install -m 0755 ${WORKDIR}/qtLauncher ${D}/usr/bin/
}
