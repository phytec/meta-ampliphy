DESCRIPTION = "Hardware development tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    alsa-utils \
    alsa-utils-scripts \
    alsa-state \
    vorbis-tools \
    libao-plugin-libalsa \
"
