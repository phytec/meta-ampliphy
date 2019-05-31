SUMMARY = "Sensor/Actuator repository for Mraa"
HOMEPAGE = "https://github.com/intel-iot-devkit/upm"
SECTION = "libs"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=66493d54e65bfc12c7983ff2e884f37f"

DEPENDS = "libjpeg-turbo mraa"

SRC_URI = "https://github.com/intel-iot-devkit/upm/archive/v${PV}.tar.gz;downloadfilename=upm-${PV}.tar.gz"
SRC_URI[md5sum] = "9a514218e744769ff4ed392f008e6ba1"
SRC_URI[sha256sum] = "7dd2f4165b71e071d100b58d6a392f3cf57b0f257c82ffabf49e931b5ed6bc23"

S = "${WORKDIR}/${PN}-${PV}"

# Depends on mraa which only supports x86 and ARM for now
COMPATIBLE_HOST = "(x86_64.*|i.86.*|aarch64.*|arm.*)-linux"

inherit distutils3-base cmake

# override this in local.conf to get needed bindings.
# BINDINGS_pn-upm="python"
# will result in only the python bindings being built/packaged.
BINDINGS ??= "python nodejs"

# nodejs isn't available for armv4/armv5 architectures
BINDINGS_armv4 ??= "python"
BINDINGS_armv5 ??= "python"

PACKAGECONFIG ??= "${@bb.utils.contains('PACKAGES', 'node-${PN}', 'nodejs', '', d)} \
 ${@bb.utils.contains('PACKAGES', '${PYTHON_PN}-${PN}', 'python', '', d)}"

PACKAGECONFIG[python] = "-DBUILDSWIGPYTHON=ON, -DBUILDSWIGPYTHON=OFF, swig-native ${PYTHON_PN},"
PACKAGECONFIG[nodejs] = "-DBUILDSWIGNODE=ON, -DBUILDSWIGNODE=OFF, swig-native nodejs-native,"

FILES_${PYTHON_PN}-${PN} = "${PYTHON_SITEPACKAGES_DIR}"
RDEPENDS_${PYTHON_PN}-${PN} += "${PYTHON_PN}"

FILES_node-${PN} = "${prefix}/lib/node_modules/"
RDEPENDS_node-${PN} += "nodejs"

### Include desired language bindings ###
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'nodejs', 'node-${PN}', '', d)}"
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'python', '${PYTHON_PN}-${PN}', '', d)}"
