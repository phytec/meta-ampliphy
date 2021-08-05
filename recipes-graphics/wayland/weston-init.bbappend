FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

INI_UNCOMMENT_ASSIGNMENTS:remove:mx8mq = "repaint-window=16"

INI_UNCOMMENT_ASSIGNMENTS:append:mx8mq = "drm-device=card0"

SRC_URI:append:mx8 = " ${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'file://weston.config', '', d)}"
