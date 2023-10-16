DESCRIPTION = "Benchmark tools used on Phytec boards"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS:${PN} = " \
    bonnie++ \
    ${@bb.utils.contains("MACHINE_FEATURES", "gpu", "glmark2", "",d)} \
    hdparm \
    iozone3 \
    iperf3 \
    lmbench \
    pmbw \
    rt-tests \
    evtest \
    perf \
    stress-ng \
    ${@bb.utils.contains("DISTRO_FEATURES", "systemd", "systemd-analyze", "",d)} \
"
