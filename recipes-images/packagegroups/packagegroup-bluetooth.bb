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
    pulseaudio-module-bluetooth-discover \
    pulseaudio-module-bluetooth-policy \
    pulseaudio-module-echo-cancel \
    pulseaudio-module-ladspa-sink \
    pulseaudio-module-loopback \
    pulseaudio-module-sine \
    pulseaudio-module-sine-source \
    pulseaudio-module-rtp-send \
    pulseaudio-module-rtp-recv \
"
