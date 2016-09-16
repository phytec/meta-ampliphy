DESCRIPTION = "bluetooth tools used on Phytec boards"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    bluez5 \
    bluez5-testtools \
    bluez5-obex \
    pulseaudio-server \
    pulseaudio-misc \
    pulseaudio-module-bluez5-device \
    pulseaudio-module-bluez5-discover \
"
