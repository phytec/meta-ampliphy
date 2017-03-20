SUMMARY = "Sensor/Actuator repository for Mraa"
SECTION = "libs"
AUTHOR = "Brendan Le Foll, Tom Ingleby, Yevgeniy Kiveisha"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=66493d54e65bfc12c7983ff2e884f37f"

DEPENDS = "libjpeg-turbo mraa"

SRC_URI = "https://github.com/intel-iot-devkit/upm/archive/v${PV}.tar.gz"
SRC_URI += "\
    file://0001-FindNodejs.cmake-parse-V8_MAJOR_VERSION-from-nodejs-.patch \
    file://0001-tcs37727-Added-upm-support-for-color-sensor-TCS37727.patch \
    file://0002-hdc1000-Added-upm-support-for-sensor-HDC1000.patch \
    file://0003-mag3110-Added-upm-support-for-sensor-MAG3110.patch \
    file://0004-tmp006-Added-upm-support-for-sensor-TMP006.patch \
    file://0005-mma8x5x-Added-upm-support-for-some-MMA8X5X-sensors.patch \
    file://0006-examples-Added-some-examples-for-added-sensors.patch \
"

SRC_URI[md5sum] = "a5d64c79346220e68c62a42607cb20f9"
SRC_URI[sha256sum] = "81d53b754c261075e7b58502bcfba6bd92a94399c9eece0ddd11a85d74356877"

inherit distutils-base pkgconfig python-dir cmake

CFLAGS_append_edison = " -msse3 -mfpmath=sse"

FILES_${PN}-doc += " ${datadir}/upm/examples/"
RDEPENDS_${PN} += " mraa"

# override this in local.conf to get a subset of bindings.
# BINDINGS_pn-upm="python"
# will result in only the python bindings being built/packaged.

BINDINGS ?= "python nodejs"

PACKAGECONFIG ??= "${@bb.utils.contains('PACKAGES', 'node-${PN}', 'nodejs', '', d)} \
 ${@bb.utils.contains('PACKAGES', 'python-${PN}', 'python', '', d)} \
 ${@bb.utils.contains('PACKAGES', '${PN}-java', 'java', '', d)}"

PACKAGECONFIG[python] = "-DBUILDSWIGPYTHON=ON, -DBUILDSWIGPYTHON=OFF, swig-native ${PYTHON_PN},"
PACKAGECONFIG[nodejs] = "-DBUILDSWIGNODE=ON, -DBUILDSWIGNODE=OFF, swig-native nodejs,"
PACKAGECONFIG[java] = "-DBUILDSWIGJAVA=ON, -DBUILDSWIGJAVA=OFF, swig-native openjdk-8-native,"


### Python ###

# Python dependency in PYTHON_PN (from poky/meta/classes/python-dir.bbclass)
# Possible values for PYTHON_PN: "python" or "python3"

# python-upm package containing Python bindings
FILES_${PYTHON_PN}-${PN} = "${PYTHON_SITEPACKAGES_DIR} \
                       ${datadir}/${BPN}/examples/python/ \
                       ${prefix}/src/debug/${BPN}/${PV}-${PR}/build/src/*/pyupm_* \
                      "
RDEPENDS_${PYTHON_PN}-${PN} += "${PYTHON_PN} mraa"
INSANE_SKIP_${PYTHON_PN}-${PN} = "debug-files"


### Node ###

# node-upm package containing Nodejs bindings
FILES_node-${PN} = "${prefix}/lib/node_modules/ \
                    ${datadir}/${BPN}/examples/javascript/ \
                   "
RDEPENDS_node-${PN} += "nodejs mraa"
INSANE_SKIP_node-${PN} = "debug-files"


### Java ###

# upm-java package containing Java bindings
FILES_${PN}-java = "${libdir}/libjava*.so \
                    ${libdir}/java/ \
                    ${datadir}/${BPN}/examples/java/ \
                    ${prefix}/src/debug/${BPN}/${PV}-${PR}/build/src/*/*javaupm_* \
                    ${libdir}/.debug/libjava*.so \
                   "

RDEPENDS_${PN}-java += "${@bb.utils.contains('PACKAGES', '${PN}-java', 'java2-runtime mraa-java', '', d)}"
INSANE_SKIP_${PN}-java = "debug-files"

export JAVA_HOME="${STAGING_DIR}/${BUILD_SYS}/usr/lib/jvm/openjdk-8-native"

cmake_do_generate_toolchain_file_append() {
  echo "
set (JAVA_AWT_INCLUDE_PATH ${JAVA_HOME}/include CACHE PATH \"AWT include path\" FORCE)
set (JAVA_AWT_LIBRARY ${JAVA_HOME}/jre/lib/amd64/libjawt.so CACHE FILEPATH \"AWT Library\" FORCE)
set (JAVA_INCLUDE_PATH ${JAVA_HOME}/include CACHE PATH \"java include path\" FORCE)
set (JAVA_INCLUDE_PATH2 ${JAVA_HOME}/include/linux CACHE PATH \"java include path\" FORCE)
set (JAVA_JVM_LIBRARY ${JAVA_HOME}/jre/lib/amd64/libjvm.so CACHE FILEPATH \"path to JVM\" FORCE)
" >> ${WORKDIR}/toolchain.cmake
}



### Include desired language bindings ###
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'java', '${PN}-java', '', d)}"
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'nodejs', 'node-${PN}', '', d)}"
PACKAGES =+ "${@bb.utils.contains('BINDINGS', 'python', 'python-${PN}', '', d)}"
