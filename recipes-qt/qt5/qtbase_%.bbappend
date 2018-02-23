FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

RDEPENDS_qtbase_append = " tslib-conf tslib-calibrate"

PACKAGECONFIG_MULTIMEDIA_append = " alsa"
PACKAGECONFIG_DEFAULT_append = " tslib"

PACKAGECONFIG_FONTS = "fontconfig"

#input devices
PACKAGECONFIG_append = " libinput xkbcommon-evdev"
PACKAGECONFIG_DEFAULT = "dbus udev libs freetype"

#for qt widget applications add this in your layer
#PACKAGECONFIG_append = " widgets"

SRC_URI += "file://res-touchscreen.rules \
            file://qtLauncher \
            file://eglfs_kms.config \
"

QT_QPA_PLATFORM ??= "eglfs"
QT_CONFIG_FLAGS += "-qpa ${QT_QPA_PLATFORM}"

do_install_append () {
	install -d ${D}${nonarch_base_libdir}/udev/rules.d
	install -m 0644 ${WORKDIR}/res-touchscreen.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}/${sysconfdir}
	install -m 0644 ${WORKDIR}/eglfs_kms.config ${D}/${sysconfdir}/eglfs_kms.config

	install -d ${D}/${bindir}
	install -m 0755 ${WORKDIR}/qtLauncher ${D}/${bindir}/qtLauncher
	sed -i 's,@QT_QPA_PLATFORM@,${QT_QPA_PLATFORM},g' ${D}/${bindir}/qtLauncher
	sed -i 's,@QT_QPA_EGLFS_KMS_CONFIG@,${sysconfdir}/eglfs_kms.config,g' ${D}/${bindir}/qtLauncher
}
