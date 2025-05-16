K3_INHERIT = ""
K3_INHERIT:k3 = "uboot-extra-env"
inherit ${K3_INHERIT}

python do_env:append:k3() {
    env_add(d, "script_offset_f", "0x700000")
    env_add(d, "script_size_f", "0x2000")
    env_add(d, "boot_script_dhcp", "net_boot_fit.scr.uimg")
    env_add(d, "fitimage_offset_f", "0x740000")
}
