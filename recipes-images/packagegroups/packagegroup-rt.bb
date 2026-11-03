DESCRIPTION = "real-time test suite and tools appropriate for real-time use"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    rt-tests \
    hwlatdetect \
    ${@bb.utils.contains('DISTRO_FEATURES', 'preempt-rt', 'rtla', '', d)} \
"
