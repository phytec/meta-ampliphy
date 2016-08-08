# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Hardware development tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    alsa-utils \
    alsa-state \
    vorbis-tools \
    ${@bb.utils.contains("DISTRO_FEATURES", "alsa", "libao-plugin-libalsa", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "pulseaudio", "libao-plugin-libpulse", "", d)} \
"
