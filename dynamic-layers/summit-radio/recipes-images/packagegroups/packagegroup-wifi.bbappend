FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}:append = " \
	${@bb.utils.contains("MACHINE_FEATURES", "lwb5p", \
		"kernel-module-lwb-if-backports \
		 lwb5plus-sdio-div-firmware \
		 summit-supplicant-lwb-if \
		 summit-supplicant-libs-60 ", \
		"", d) \
	} \
"
