FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

RDEPENDS:${PN}:append = " \
	${@bb.utils.contains("MACHINE_FEATURES", "lwb5p", \
		"kernel-module-lwb5p-backports-summit \
		 lwb5plus-sdio-div-firmware \
		 sterling-supplicant-lwb", \
		"", d) \
	} \
"
