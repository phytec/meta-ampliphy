FILESEXTRAPATHS:prepend := "${CERT_PATH}/rauc:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += "phytec-dev-ca-native"
do_fetch[depends] += "phytec-dev-ca-native:do_install"

# set path to the rauc keyring, which is installed in the image
RAUC_KEYRING_FILE ?= "${CERT_PATH}/main-ca/mainca-rsa.crt.pem"

SRC_URI += " \
    file://10-update-usb.rules \
    file://update-usb@.service \
    file://update_usb.sh \
    file://rauc_downgrade_barrier.sh \
    ${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'file://system_emmc.conf', 'file://system_nand.conf', d)} \
    file://rauc-pre-install.sh \
    file://rauc-handle-secrets.sh \
    file://rauc-post-install.sh \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PACKAGES =+ "rauc-update-usb"

SYSTEMD_PACKAGES += "rauc-update-usb"
SYSTEMD_SERVICE:rauc-update-usb = "update-usb@.service"
SYSTEMD_AUTO_ENABLE:rauc-update-usb = "enable"

# configure the downgrade barrier, here you could move back from a
# production system to a development mode by setting r0
DOWNGRADE_BARRIER_VERSION ?= "${RAUC_BUNDLE_VERSION}"

do_install:prepend() {
	# check for default system.conf from meta-rauc
	shasum=$(sha256sum "${WORKDIR}/system.conf" | cut -d' ' -f1)
	if [ "$shasum" = "27ec3e7595315fbb283d1a95e870f6a76a2c296b39866fd8ffb01669c1b39942" ]; then
		bbnote "No project specific system.conf has been provided. We use the Phytec RDK specific config files."
		cp ${WORKDIR}/${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'system_emmc.conf', 'system_nand.conf', d)} ${WORKDIR}/system.conf
	fi
	sed -i -e 's!@MACHINE@!${MACHINE}!g' ${WORKDIR}/system.conf

	echo "${DOWNGRADE_BARRIER_VERSION}" > ${WORKDIR}/downgrade_barrier_version
}

do_install:append() {
	# check for problematic certificate setups
	shasum=$(sha256sum "${WORKDIR}/${RAUC_KEYRING_FILE}" | cut -d' ' -f1)
	if [ "$shasum" = "91efd86dfbffa360c909b06b54902348075c5ba7902ad1ec30d25527a1f8ca09" ]; then
		bbwarn "You're including Phytec's Development Keyring in the rauc bundle. Please create your own!"
	fi

	install -d ${D}${bindir}
	install -d ${D}${libdir}
	install -d ${D}${libdir}/rauc

	install -m 0774 ${WORKDIR}/update_usb.sh ${D}${bindir}
	install -m 0774 ${WORKDIR}/rauc_downgrade_barrier.sh ${D}${bindir}

	install -d ${D}${systemd_unitdir}/system/
	install -m 0644 ${WORKDIR}/update-usb@.service ${D}${systemd_unitdir}/system/

	install -d ${D}${nonarch_base_libdir}/udev/rules.d/
	install -m 0644 ${WORKDIR}/10-update-usb.rules ${D}${nonarch_base_libdir}/udev/rules.d/

	install -d ${D}${sysconfdir}/rauc
	install -m 0644 ${WORKDIR}/downgrade_barrier_version ${D}${sysconfdir}/rauc/downgrade_barrier_version

	install -m 0774 ${WORKDIR}/rauc-pre-install.sh ${D}${libdir}/rauc
	install -m 0774 ${WORKDIR}/rauc-handle-secrets.sh ${D}${libdir}/rauc
	install -m 0774 ${WORKDIR}/rauc-post-install.sh ${D}${libdir}/rauc
}

FILES:rauc-update-usb += " \
    ${bindir}/update_usb.sh \
    ${systemd_unitdir}/system/update-usb@.service \
    ${nonarch_base_libdir}/udev/rules.d/10-update-usb.rules \
"

RDEPENDS:${PN} += " \
    ${@bb.utils.contains_any('PREFERRED_PROVIDER_virtual/bootloader', 'u-boot u-boot-imx', 'libubootenv-bin', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'dosfstools e2fsprogs', '', d)} \
"
