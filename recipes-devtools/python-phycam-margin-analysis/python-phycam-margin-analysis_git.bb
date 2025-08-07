SUMMARY = "Python phyCAM-L Margin Analysis"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = "git://github.com/phytec/python-phycam-margin-analysis.git;protocol=https;branch=${BRANCH}"
BRANCH = "main"

PV = "0.16+git${SRCPV}"
SRCREV = "e3854df28287dfb5ed899f152d073969220e2e04"

S = "${WORKDIR}/git"

inherit setuptools3

RDEPENDS:${PN} += "python3-smbus2 python3-core"
