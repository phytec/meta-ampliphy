# Copyright (C) 2014 Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Userland softwareservices found in all Phytec BSPs"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} = " \
    gdbserver \
    perf \
    strace \
    openssh \
    openssh-sftp-server \
    rsync \
    htop \
    crda \
    ${@bb.utils.contains("MACHINE_FEATURES", "wlan", "wireless-tools wpa-supplicant iw hostapd", "", d)} \
    kbd \
    kbd-keymaps \
"

RDEPENDS_${PN}_append_ti33x = " \
    ${@bb.utils.contains("MACHINE_FEATURES", "wlan", "linux-firmware-wl12xx wl12xx-calibrator", "", d)} \
"
