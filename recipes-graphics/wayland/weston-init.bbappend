FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

SRC_URI:append:mx8 = " ${@bb.utils.contains('DISTRO_FEATURES', 'wayland x11', 'file://weston.config', '', d)}"
