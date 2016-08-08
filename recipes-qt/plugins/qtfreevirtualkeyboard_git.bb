DESCRIPTION = "A QML based on screen virtual keyboard for embedded QML applications"
SUMMARY = "Touchscreen driver for integrated mouse pointer in VirtualBox"
# There is no generic header for the Beerware license, we need to provide it
# in the license directory
LICENSE = "Beerware-Olszak"
LIC_FILES_CHKSUM = "file://LICENSE;md5=db94a430cc061dc7f8b05b5087109d6e"

PV = "1.0+gitr${SRCPV}"

DEPENDS = "qtbase qtdeclarative"

SRC_URI = "git://git.phytec.de/QtFreeVirtualKeyboard"
SRCREV = "70e1f5f8d4929bc3d2d0ab0bb9291d198460bbec"
S = "${WORKDIR}/git"

inherit qmake5

FILES_${PN} = "${OE_QMAKE_PATH_PLUGINS} ${OE_QMAKE_PATH_QML}"
FILES_${PN}-dbg = "${OE_QMAKE_PATH_PLUGINS}/platforminputcontexts/.debug/"
FILES_${PN}-dev = "/usr/src/debug"
