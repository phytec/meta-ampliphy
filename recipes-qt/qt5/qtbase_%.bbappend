FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG_MULTIMEDIA:append = " alsa"
PACKAGECONFIG_DEFAULT:append = " tslib"

PACKAGECONFIG_FONTS = "fontconfig"

#input devices
PACKAGECONFIG:append = " libinput xkbcommon"
PACKAGECONFIG_DEFAULT = "dbus udev libs freetype \
    ${@bb.utils.contains('DISTRO_FEATURES', 'qtwidgets', 'widgets', '', d)} \
"
# accessibility is necessary for qtquickcontrols-qmlplugins
PACKAGECONFIG_DEFAULT += "accessibility"

PACKAGECONFIG_append_am62xx = " widgets"

SRC_URI += "file://res-touchscreen.rules"

do_install:append () {
	install -d ${D}${nonarch_base_libdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/res-touchscreen.rules ${D}${nonarch_base_libdir}/udev/rules.d/
}

RDEPENDS:${PN} += "qtbase-machine-config tslib-conf tslib-calibrate"
