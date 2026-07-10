# Loaded from the u-boot bbappends only when secureboot is in
# DISTRO_FEATURES, so everything here applies unconditionally.
# FILESEXTRAPATHS is set by the including bbappend.

inherit u-boot-dts-pubkeynode
inherit uboot-extra-env

UBOOT_DISABLE_CONSOLE ?= "0"

SRC_URI:append = " \
    file://deselect-commands.cfg \
    file://default-env.cfg \
    file://bootcommand.cfg \
    ${@bb.utils.contains('UBOOT_SIGN_ENABLE','1','file://fitimage.cfg', '', d)} \
    ${@oe.utils.conditional('UBOOT_DISABLE_CONSOLE', '1', 'file://disable-console.cfg', '', d)} \
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

# default-env.cfg enables ENV_WRITEABLE_LIST, which rejects any variable
# imported from the stored environment unless it is marked writeable in
# CFG_ENV_FLAGS_LIST_STATIC.
# Comma-separated <name>:<flags> entries, no spaces.
UBOOT_ENV_FLAGS_LIST_STATIC ?= "BOOT_ORDER:sw,BOOT_system0_LEFT:dw,BOOT_system1_LEFT:dw"

EXTRA_OEMAKE:append:k3 = ' KCFLAGS=-DCFG_ENV_FLAGS_LIST_STATIC=\\\"${UBOOT_ENV_FLAGS_LIST_STATIC}\\\"'

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
