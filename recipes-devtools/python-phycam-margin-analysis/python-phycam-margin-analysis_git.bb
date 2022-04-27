SUMMARY = "Python phyCAM-L Margin Analysis"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "git://github.com/phytec/python-phycam-margin-analysis.git;protocol=https;branch=main"

PV = "1.0+git${SRCPV}"
SRCREV = "c086f3b279cdacca90eaa4a64e7104387c27611d"

S = "${WORKDIR}/git"

inherit setuptools3

RDEPENDS:${PN} += "python3-smbus2 python3-core"
