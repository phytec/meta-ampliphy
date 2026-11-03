# TODO: Drop once meta-phytec transitioned to u-boot-phytec-* naming

FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

require ${@bb.utils.contains('DISTRO_FEATURES', 'secureboot', 'recipes-bsp/u-boot/secureboot.inc', '', d)}

SRC_URI:append = " ${@bb.utils.contains('DISTRO_FEATURES', 'hardening', 'file://hardening.cfg', '', d)}"
