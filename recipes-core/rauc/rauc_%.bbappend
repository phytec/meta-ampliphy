FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += " \
    file://10-update-usb.rules \
    file://update-usb@.service \
    file://update_usb.sh \
    file://rauc_downgrade_barrier.sh \
    file://rauc-pre-install.sh \
    file://rauc-handle-secrets.sh \
    file://rauc-post-install.sh \
    ${@bb.utils.contains('DISTRO_FEATURES', 'rauc-appfs', 'file://is-parent-active file://10-appfs.rules', '', d)} \
"

PACKAGES =+ "rauc-update-usb"

SYSTEMD_PACKAGES += "rauc-update-usb"
SYSTEMD_SERVICE:rauc-update-usb = "update-usb@.service"
SYSTEMD_AUTO_ENABLE:rauc-update-usb = "enable"

# configure the downgrade barrier, here you could move back from a
# production system to a development mode by setting r0
DOWNGRADE_BARRIER_VERSION ?= "${RAUC_BUNDLE_VERSION}"

do_configure:append() {
	echo "${DOWNGRADE_BARRIER_VERSION}" > ${UNPACKDIR}/downgrade_barrier_version
}

do_patch[postfuncs] += "${@bb.utils.contains('DISTRO_FEATURES', 'rauc-appfs', 'parse_appfs_rules', '', d)}"
parse_appfs_rules() {
	sed -i \
		-e 's!@EMMC_DEV@!${EMMC_DEV}!g' \
		-e 's!@LIBDIR@!${libdir}!g' \
		-e 's!@PN@!${PN}!g' \
		${UNPACKDIR}/10-appfs.rules
}

do_install:append() {
	install -d ${D}${bindir}
	install -d ${D}${libdir}
	install -d ${D}${libdir}/rauc

	install -m 0774 ${UNPACKDIR}/update_usb.sh ${D}${bindir}
	install -m 0774 ${UNPACKDIR}/rauc_downgrade_barrier.sh ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${UNPACKDIR}/update-usb@.service ${D}${systemd_unitdir}/system/

	install -d ${D}${nonarch_base_libdir}/udev/rules.d/
	install -m 0644 ${UNPACKDIR}/10-update-usb.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}${sysconfdir}/rauc
	install -m 0644 ${UNPACKDIR}/downgrade_barrier_version ${D}${sysconfdir}/rauc/downgrade_barrier_version

	install -m 0774 ${UNPACKDIR}/rauc-pre-install.sh ${D}${libdir}/rauc
	install -m 0774 ${UNPACKDIR}/rauc-handle-secrets.sh ${D}${libdir}/rauc
	install -m 0774 ${UNPACKDIR}/rauc-post-install.sh ${D}${libdir}/rauc
}
do_install:append:rauc-appfs() {
	install -m 754 ${UNPACKDIR}/is-parent-active ${D}${libdir}/rauc
	install -m 644 ${UNPACKDIR}/10-appfs.rules ${D}${nonarch_base_libdir}/udev/rules.d/
}

FILES:rauc-update-usb += " \
    ${bindir}/update_usb.sh \
    ${systemd_unitdir}/system/update-usb@.service \
    ${nonarch_base_libdir}/udev/rules.d/10-update-usb.rules \
"
FILES:${PN}:append:rauc-appfs = " \
    ${libdir}/rauc/is-parent-active \
    ${nonarch_base_libdir}/udev/rules.d/10-appfs.rules \
"

RDEPENDS:${PN} += " \
    ${@bb.utils.contains_any('PREFERRED_PROVIDER_virtual/bootloader', 'u-boot u-boot-imx', 'libubootenv-bin', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'dosfstools e2fsprogs', '', d)} \
"
