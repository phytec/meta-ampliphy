SUMMARY = "Packagegroup for using cryptodev hardware acceleration"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    cryptodev-module \
    cryptodev-tests \
    cryptodev-linux \
    openssl-engines \
"
