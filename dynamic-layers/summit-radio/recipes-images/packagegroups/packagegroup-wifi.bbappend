FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SUMMIT_SUPPLICANT_PACKAGES = " \
    kernel-module-lwb-if-backports \
    lwb5plus-sdio-div-firmware \
    summit-supplicant-lwb-if \
    summit-supplicant-libs-60 \
"

RDEPENDS:${PN}:append = " \
       ${@bb.utils.contains("MACHINE_FEATURES", "lwb5p", \
            "${@oe.utils.conditional('PREFERRED_PROVIDER_virtual/kernel', 'linux-phytec-ti', '${SUMMIT_SUPPLICANT_PACKAGES}', '', d)}", \
        "", d) \
       } \
"
