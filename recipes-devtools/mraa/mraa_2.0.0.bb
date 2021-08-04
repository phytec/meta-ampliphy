SUMMARY = "Linux Library for low speed I/O Communication"
HOMEPAGE = "https://github.com/intel-iot-devkit/mraa"
SECTION = "libs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING;md5=4b92a3b497d7943042a6db40c088c3f2"

SRC_URI = "https://github.com/intel-iot-devkit/${BPN}/archive/v${PV}.tar.gz"
SRC_URI[md5sum] = "1a5d8eaab441655c1e8741e35a702b3e"
SRC_URI[sha256sum] = "c9f3c3741c6894be5516adecfe6b55a38960b6718b268a9afd645f7955e5a716"
SRC_URI += "\
            file://0001-FindNodejs.cmake-parse-V8_MAJOR_VERSION-from-nodejs-.patch \
            file://0002-phyboard-mira-add-platform-support.patch"

S = "${WORKDIR}/${BPN}-${PV}"

# CMakeLists.txt checks the architecture, only x86 and ARM supported for now
COMPATIBLE_HOST = "(x86_64.*|i.86.*|aarch64.*|arm.*)-linux"

inherit cmake distutils3-base

DEPENDS += "json-c"

EXTRA_OECMAKE:append = " -DINSTALLTOOLS:BOOL=ON -DFIRMATA=ON -DCMAKE_SKIP_RPATH=ON"

# Prepend mraa-utils to make sure bindir ends up in there
PACKAGES =+ "${PN}-utils"

FILES:${PN}-doc += "${datadir}/mraa/examples/"

FILES:${PN}-utils = "${bindir}/"

# override this in local.conf to get needed bindings.
# BINDINGS:pn-mraa="python"
# will result in only the python bindings being built/packaged.
BINDINGS ??= "python nodejs"

PACKAGECONFIG ??= "${@bb.utils.contains('PACKAGES', 'node-${PN}', 'nodejs', '', d)} \
 ${@bb.utils.contains('PACKAGES', '${PYTHON_PN}-${PN}', 'python', '', d)}"

PACKAGECONFIG[python] = "-DBUILDSWIGPYTHON=ON, -DBUILDSWIGPYTHON=OFF, swig-native ${PYTHON_PN},"
PACKAGECONFIG[nodejs] = "-DBUILDSWIGNODE=ON, -DBUILDSWIGNODE=OFF, swig-native nodejs-native,"
PACKAGECONFIG[ft4222] = "-DUSBPLAT=ON -DFTDI4222=ON, -DUSBPLAT=OFF -DFTDI4222=OFF,, libft4222"

FILES:${PYTHON_PN}-${PN} = "${PYTHON_SITEPACKAGES_DIR}/"
RDEPENDS:${PYTHON_PN}-${PN} += "${PYTHON_PN}"

FILES:node-${PN} = "${prefix}/lib/node_modules/"
RDEPENDS:node-${PN} += "nodejs"

### Include desired language bindings ###
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'nodejs', 'node-${PN}', '', d)}"
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'python', '${PYTHON_PN}-${PN}', '', d)}"
