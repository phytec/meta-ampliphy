FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += "file://select-nice.cfg"

SRC_URI += "file://deselect-ip-tool.cfg"
SRC_URI += "${@bb.utils.contains("DISTRO_FEATURES", "sysvinit", "", "file://deselect-ifupdown.cfg", d)}"
SRC_URI += "file://select-showkey.cfg"
SRC_URI[vardeps] += "DISTRO_FEATURES"

SRC_URI += "${@bb.utils.contains("DISTRO_FEATURES", "systemd", "file://deselect-syslogd-klogd.cfg", "", d)}"

SYSTEMD_SERVICE_${PN}-syslog = ""
ALTERNATIVE_${PN}-syslog_remove = "syslog-conf"
RRECOMMENDS_busybox_remove ="busybox-syslog"

SRC_URI += "${@bb.utils.contains("DISTRO_FEATURES", "systemd", "file://deselect-dhcp-stuff.cfg", "", d)}"
RRECOMMENDS_busybox_remove = "${@bb.utils.contains("DISTRO_FEATURES", "systemd", "busybox-udhcpc", "", d)}"

SRC_URI += "${@bb.utils.contains("DISTRO_FEATURES", "tiny", "file://poky-tiny.cfg", "", d)}"
