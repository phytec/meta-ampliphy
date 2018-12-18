FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = "file://print_issue.sh \
                  file://qt_setup_env.sh \
"
dirs755_append = " ${sysconfdir}/profile.d"

do_install_append () {
	install -m 0755 ${WORKDIR}/print_issue.sh ${D}${sysconfdir}/profile.d/print_issue.sh
	install -m 0755 ${WORKDIR}/qt_setup_env.sh ${D}${sysconfdir}/profile.d/qt_setup_env.sh
}

do_install_basefilesissue_append() {
   if [ -n "${DISTRO_NAME}" ]; then
       sed -i 's/%h//g' ${D}${sysconfdir}/issue.net
   fi
}
