FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

K3_INHERIT = ""
K3_INHERIT:k3 = "uboot-extra-env"
inherit ${K3_INHERIT}

SRC_URI:append:update = " file://rauc.cfg"

SRC_URI:append:secureboot = " \
    file://disable-insecure-bootmeths.cfg \
"

python do_env:append:k3() {
    env_add(d, "script_offset_f", "0x700000")
    env_add(d, "script_size_f", "0x2000")
    env_add(d, "boot_script_dhcp", "net_boot_fit.scr.uimg")
    env_add(d, "fitimage_offset_f", "0x740000")
}
