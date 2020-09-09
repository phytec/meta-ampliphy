FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " file://weston.ini"

do_install_append() {
	install -d ${D}${sysconfdir}/xdg/weston
	install -m 0644 ${WORKDIR}/weston.ini ${D}${sysconfdir}/xdg/weston
}

FILES_${PN} += "${sysconfdir}/xdg/weston"
