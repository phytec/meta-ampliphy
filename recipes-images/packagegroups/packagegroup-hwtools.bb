DESCRIPTION = "Hardware development tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    packagegroup-hwtools-init \
    packagegroup-hwtools-diagnostic \
    bmap-tools \
"
