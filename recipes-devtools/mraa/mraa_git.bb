require mraa.inc

#SRC_URI = "https://github.com/intel-iot-devkit/mraa/archive/v${PV}.tar.gz"
SRC_URI = "git://github.com/intel-iot-devkit/mraa.git"
SRC_URI += "\
    file://0001-FindNodejs.cmake-parse-V8_MAJOR_VERSION-from-nodejs-.patch \
    file://0002-phyboard-mira-add-platform-support.patch \
"

PV = "1.5.1+gitr${SRCPV}"
SRCREV = "23fd11c4f73d368de4ece44d4735bde6c8db08eb"

S = "${WORKDIR}/git"

COMPATIBLE_MACHINE  =  "phyboard-wega"
COMPATIBLE_MACHINE .= "|phyboard-mira-imx6-13"
