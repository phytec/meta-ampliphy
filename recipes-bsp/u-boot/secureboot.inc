# Loaded from the u-boot bbappends only when secureboot is in
# DISTRO_FEATURES, so everything here applies unconditionally.
# FILESEXTRAPATHS is set by the including bbappend.

inherit u-boot-dts-pubkeynode
inherit uboot-extra-env

SRC_URI:append = " \
    file://deselect-commands.cfg \
    file://default-env.cfg \
    ${@bb.utils.contains('UBOOT_SIGN_ENABLE','1','file://fitimage.cfg', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'disable-console', 'file://disable-console.cfg', '', d)} \
"

SRC_URI:append:mx8m-generic-bsp = " \
    file://hab.cfg \
"
SRC_URI:append:mx8m-nxp-bsp = " \
    ${@bb.utils.contains('FITIMAGE_SIGN_ENGINE','nxphab','file://disable-fit-signature.cfg', '', d)} \
"
SRC_URI:append:mx91-generic-bsp = " \
    file://ahab.cfg \
"
SRC_URI:append:mx93-generic-bsp = " \
    file://ahab.cfg \
"

kconfig_set() {
    bbnote "Setting $1 in configs to $2"
    if [ "$2" = "n" ]; then
        line="# CONFIG_$1 is not set"
    else
        line="CONFIG_$1=$2"
    fi

    for config in ${UBOOT_MACHINE}; do
    if [ "$(grep -E CONFIG_$1[=\ ] ${S}/configs/${config})" ]; then
        sed -i "/CONFIG_$1[= ]/c\\$line" "${S}/configs/${config}"
    else
        echo "$line" >> "${S}/configs/${config}"
    fi
    done
}

set_fitimage_key() {
    kconfig_set DEVICE_TREE_INCLUDES '"signature_node.dtsi"'
    cp "${FITIMAGE_PUBKEY_SIGNATURE_PATH}" "${S}/arch/arm/dts/"
}

python do_patch:append () {
    if d.getVar("UBOOT_SIGN_ENABLE") == "1" and d.getVar('FITIMAGE_SIGN_ENGINE') != 'nxphab':
        bb.build.exec_func("set_fitimage_key", d)
}

do_uboot_assemble_fitimage:prepend () {
    if echo "${UBOOT_SIGN_KEYDIR}" | grep -q "pkcs11:"; then
        setup_pkcs11_env
    fi
}

python do_env:append() {
    env_add(d, "silent", "1")
}
