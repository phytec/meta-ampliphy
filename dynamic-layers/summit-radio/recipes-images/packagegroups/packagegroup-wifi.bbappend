FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}:append = " \
	${@bb.utils.contains("MACHINE_FEATURES", "lwb5p", \
		"kernel-module-lwb-if-backports \
		 lwb5plus-usb-div-firmware ", \
		"", d) \
	} \
"
