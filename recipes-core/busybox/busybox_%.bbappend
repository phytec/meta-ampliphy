FILESEXTRAPATHS_prepend := "${THISDIR}:"

SRC_URI += "file://deselect-ip-tool.cfg"
SRC_URI += "${@bb.utils.contains("DISTRO_FEATURES", "sysvinit", "", "file://deselect-ifupdown.cfg", d)}"
SRC_URI += "file://select-showkey.cfg"
SRC_URI[vardeps] += "DISTRO_FEATURES"
