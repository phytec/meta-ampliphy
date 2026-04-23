# TODO: Drop once meta-phytec transitioned to u-boot-phytec-* naming

FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

require ${@bb.utils.contains('DISTRO_FEATURES', 'secureboot', 'recipes-bsp/u-boot/secureboot.inc', '', d)}
require ${@bb.utils.contains('DISTRO_FEATURES', 'hardening', 'recipes-bsp/u-boot/hardening.inc', '', d)}
