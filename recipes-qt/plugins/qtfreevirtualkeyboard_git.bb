DESCRIPTION = "A QML based on screen virtual keyboard for embedded QML applications"
SUMMARY = "Touchscreen driver for integrated mouse pointer in VirtualBox"
LICENSE = "GPL-2.0"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/GPL-2.0;md5=801f80980d171dd6425610833a22dbe6"

PV = "1.0+gitr${SRCPV}"

DEPENDS = "qtbase qtdeclarative"

SRC_URI = " \
    git://github.com/githubuser0xFFFF/QtFreeVirtualKeyboard \
    file://0001-InputPanel-minor-layout-modification.patch \
    file://0002-Keys-add-German-keys.patch \
    file://0003-move-some-messages-from-console-log-to-debug-out.patch \
"
SRCREV = "3cc47af7c9296a509fee055e42999012833806a5"
S = "${WORKDIR}/git/src"
PATCHTOOL = "git"

inherit qmake5

FILES_${PN} = "${OE_QMAKE_PATH_PLUGINS} ${OE_QMAKE_PATH_QML}"
FILES_${PN}-dbg = "${OE_QMAKE_PATH_PLUGINS}/platforminputcontexts/.debug/"
FILES_${PN}-dev = "/usr/src/debug"
