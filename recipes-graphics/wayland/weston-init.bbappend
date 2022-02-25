FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

INI_UNCOMMENT_ASSIGNMENTS:remove:mx8mq-nxp-bsp = "repaint-window=16"

INI_UNCOMMENT_ASSIGNMENTS:append:mx8mq-nxp-bsp = "drm-device=card0"

SRC_URI:append:mx8-nxp-bsp = " ${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'file://weston.config', '', d)}"
