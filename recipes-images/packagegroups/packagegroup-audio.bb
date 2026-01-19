DESCRIPTION = "Audio tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    alsa-utils \
    alsa-utils-alsa-info \
    alsa-utils-alsaconf \
    alsa-state \
    vorbis-tools \
    libao-plugin-libalsa \
"
