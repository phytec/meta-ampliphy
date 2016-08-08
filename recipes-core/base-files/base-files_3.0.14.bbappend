FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "file://print_issue.sh"
dirs755_append = " ${sysconfdir}/profile.d"

do_install_append () {
	install -m 0755 ${WORKDIR}/print_issue.sh ${D}${sysconfdir}/profile.d/print_issue.sh
}

do_install_basefilesissue_append() {
   if [ -n "${DISTRO_NAME}" ]; then
       sed -i 's/%h//g' ${D}${sysconfdir}/issue.net
   fi
}
