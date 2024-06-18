RDEPENDS:${PN}:append:am57xx = " \
    gstreamer1.0-plugins-hevc \
    ${@bb.utils.contains('MACHINE_FEATURES', 'mmip', "gstreamer1.0-plugins-vpe", '', d)} \
"
