DESCRIPTION = "real-time test suite and tools appropriate for real-time use"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    rt-tests \
    hwlatdetect \
"
