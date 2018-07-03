FILESEXTRAPATHS_prepend := "${CERT_PATH}:"
FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

SRC_URI_append := " \
    file://10-update-usb.rules \
    file://update-usb@.service \
    file://update_usb.sh \
    file://rauc_downgrade_barrier.sh \
    file://system_nand.conf \
    file://system_emmc.conf \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

SYSTEMD_PACKAGES += "update-usb"
SYSTEMD_SERVICE_update-usb = "update-usb@.service"
SYSTEMD_AUTO_ENABLE_update-usb = "enable"

do_install_prepend() {
	# check for default system.conf from meta-rauc
	shasum=$(sha256sum "${WORKDIR}/system.conf" | cut -d' ' -f1)
	if [ "$shasum" = "cb8c74d6fefea692c4284bb80ec24385c74f3c46a921b8f57334c7a5a3cf1312" ]; then
		bbnote "No project specific system.conf has been provided. We use the Phytec RDK specific config files."
		cp ${WORKDIR}/${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'system_emmc.conf', 'system_nand.conf', d)} ${WORKDIR}/system.conf
	fi
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
}

FILES_${PN} += " \
    ${bindir}/update_usb.sh \
    ${systemd_unitdir}/system/update-usb@.service \
    ${base_libdir}/udev/rules.d/10-update-usb.rules \
"
RDEPENDS_${PN}_append = " bash"

PACKAGES =+ "update-usb"
RRECOMMENDS_${PN}_append = " update-usb"
