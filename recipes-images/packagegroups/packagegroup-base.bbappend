RDEPENDS:packagegroup-base-3g += " \
    modemmanager \
"

RDEPENDS:packagegroup-base-alsa += " \
    alsa-utils \
    alsa-utils-scripts \
    vorbis-tools \
    libao-plugin-libalsa \
"

RDEPENDS:packagegroup-base-bluetooth += " \
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
    ezurio-sterling-firmware \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "linux-firmware-ibt-misc", "", d)} \
"
RDEPENDS:packagegroup-base-bluetooth:append:am57xx = " bt-fw"
RDEPENDS:packagegroup-base-bluetooth:append:mx8x-generic-bsp = " brcm-patchram-plus"

RDEPENDS:packagegroup-base-rauc += " \
    rauc-hawkbit-updater \
    rauc-update-usb \
"

RDEPENDS:packagegroup-base-wifi += " \
    hostapd \
    ezurio-sterling-firmware \
    linux-firmware-wl18xx \
    ${@bb.utils.contains("MACHINE_FEATURES", "pci", "linux-firmware-iwlwifi", "", d)} \
"
