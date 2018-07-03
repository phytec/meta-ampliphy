FILESEXTRAPATHS_prepend := "${CERT_PATH}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/shared:"
FILESEXTRAPATHS_prepend_ti33x := "${THISDIR}/ti33x:"
FILESEXTRAPATHS_prepend_rk3288 := "${THISDIR}/rk3288:"
FILESEXTRAPATHS_prepend_mx6 := "${THISDIR}/mx6:"

SRC_URI_append := " \
    file://10-update-usb.rules \
    file://update-usb@.service \
    file://update_usb.sh \
    file://rauc_downgrade_barrier.sh \
    file://system_nand.conf \
    file://system_emmc.conf \
    file://hawkbit.config \
"

SYSTEMD_PACKAGES += "update-usb"
SYSTEMD_SERVICE_update-usb = "update-usb@.service"
SYSTEMD_AUTO_ENABLE_update-usb = "enable"

do_install_prepend() {
	cp ${WORKDIR}/${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'system_emmc.conf', 'system_nand.conf', d)} ${WORKDIR}/system.conf
	sed -i -e 's!@DISTRO@!${DISTRO}!g' ${WORKDIR}/system.conf
	echo "${DISTRO_VERSION}" > ${WORKDIR}/version
}

do_install_append() {
	# check for problematic certificate setups
	shasum=$(sha256sum "${WORKDIR}/${RAUC_KEYRING_FILE}" | cut -d' ' -f1)
	if [ "$shasum" = "0b275b5cba70771b1ab055fa0f72402f141a39789dc057b46ef6a82cec6de60c" ]; then
		bbwarn "You're using Phytec's Development Certificate for signing rauc bundles. Please create your own!"
	fi

	install -d ${D}${bindir}
	install -m 0774 ${WORKDIR}/update_usb.sh ${D}${bindir}
	install -m 0774 ${WORKDIR}/rauc_downgrade_barrier.sh ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/update-usb@.service ${D}${systemd_unitdir}/system/

	install -d ${D}${base_libdir}/udev/rules.d/
	install -m 0666 ${WORKDIR}/10-update-usb.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}${sysconfdir}/rauc
	install -m 0644 ${WORKDIR}/version ${D}${sysconfdir}/rauc/version
	install -m 0644 ${WORKDIR}/hawkbit.config ${D}${sysconfdir}/rauc/hawkbit.config
}

FILES_${PN} += " \
    ${bindir}/update_usb.sh \
    ${systemd_unitdir}/system/update-usb@.service \
    ${base_libdir}/udev/rules.d/10-update-usb.rules \
    ${sysconfdif}/rauc/hawkbit.config \
"
RDEPENDS_${PN}_append = " bash"

PACKAGES =+ "update-usb"
RRECOMMENDS_${PN}_append = " update-usb"
