DESCRIPTION = "Benchmark tools used on Phytec boards"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    bonnie++ \
    hdparm \
    iozone3 \
    iperf3 \
    lmbench \
    pmbw \
    rt-tests \
    evtest \
    perf \
    stress \
    ${@bb.utils.contains("DISTRO_FEATURES", "systemd", "systemd-analyze", "",d)} \
"
