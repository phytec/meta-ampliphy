SUMMARY = "A module that implements the CRC8 hash algorithm for Python 2 and 3."
HOMEPAGE = "https://github.com/niccokunzmann/crc8"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=c65c48f212e715ad312d60ee70a869c2"

S = "${WORKDIR}/git"

SRC_URI = "git://github.com/niccokunzmann/crc8.git;branch=master;protocol=git"
SRCREV = "b6d63e65ca333b67c50f780d1025772e1f3574cc"

SRC_URI[md5sum] = "866b655ef1199118021ae543bf8546ad"
SRC_URI[sha256sum] = "569f8702bc01dd6008c12bda6eb71308c1e80d4adec4ed85ae5fa8a145475a24"

RDEPENDS_${PN} = ""

