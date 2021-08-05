FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

INI_UNCOMMENT_ASSIGNMENTS_remove_mx8mq = "repaint-window=16"

INI_UNCOMMENT_ASSIGNMENTS_append_mx8mq = "drm-device=card0"

SRC_URI_append_mx8 = " ${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'file://weston.config', '', d)}"
