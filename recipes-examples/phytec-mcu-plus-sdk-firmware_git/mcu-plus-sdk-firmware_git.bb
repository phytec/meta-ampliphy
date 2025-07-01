DESCRIPTION = "Install a PHYTEC mcu example program"

LICENSE = "BSD-3-Clause"
LIC_FILES_CHKSUM = "file://LICENSE;md5=080d34b4bf1f10085a386ddf23f784fa"

SRCREV = "f7b2d4e4152540201a46a5924ae568255ba56d37"
SRC_URI = "git://github.com/phytec/mcu-plus-sdk-firmware;protocol=https;branch=main"

INSANE_SKIP:${PN} += "arch"
PV = "0.3git${SRCPV}"
FILES:${PN} += "${nonarch_base_libdir}/firmware/"

do_install:am62xx() {
	install -d ${D}${nonarch_base_libdir}/firmware/
	install -m 0644 ${S}/am62x/m4f0/am62-mcu-m4f0_0-fw \
			${D}${nonarch_base_libdir}/firmware/am62-mcu-m4f0_0-fw
}

do_install:am64xx() {
	install -d ${D}${nonarch_base_libdir}/firmware/
	install -m 0644 ${S}/am64x/m4f0/am64-mcu-m4f0_0-fw \
			${D}${nonarch_base_libdir}/firmware/am64-mcu-m4f0_0-fw
	install -m 0644 ${S}/am64x/r5f0/am64-main-r5f0_0-fw \
			${D}${nonarch_base_libdir}/firmware/am64-main-r5f0_0-fw
	install -m 0644 ${S}/am64x/r5f0/am64-main-r5f0_1-fw \
			${D}${nonarch_base_libdir}/firmware/am64-main-r5f0_1-fw
	install -m 0644 ${S}/am64x/r5f1/am64-main-r5f1_0-fw \
			${D}${nonarch_base_libdir}/firmware/am64-main-r5f1_0-fw
	install -m 0644 ${S}/am64x/r5f1/am64-main-r5f1_1-fw \
			${D}${nonarch_base_libdir}/firmware/am64-main-r5f1_1-fw
}

do_install:am62axx() {
	install -d ${D}${nonarch_base_libdir}/firmware/
	install -m 0644 ${S}/am62ax/mcu-r5f0/am62a-mcu-r5f0_0-fw \
			${D}${nonarch_base_libdir}/firmware/am62a-mcu-r5f0_0-fw
}
