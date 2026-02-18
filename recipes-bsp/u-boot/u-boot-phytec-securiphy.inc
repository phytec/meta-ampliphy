FILESEXTRAPATHS:prepend := "${THISDIR}/features:"

inherit uboot-extra-env

SRC_URI:append = " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'disable-console', 'file://disable-console.cfg', '', d)} \
"

python do_env:append() {
    env_add(d, "silent", "1")
}
