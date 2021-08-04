SUMMARY = "Python phyCAM-L Margin Analysis"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "git://github.com/phytec/python-phycam-margin-analysis.git;protocol=https;branch=main"

PV = "1.0+git${SRCPV}"
SRCREV = "2ce2d0295a8b6df50000873315644b9c56a0a690"

S = "${WORKDIR}/git"

inherit setuptools3

RDEPENDS_${PN} += "python3-smbus python3-core"
