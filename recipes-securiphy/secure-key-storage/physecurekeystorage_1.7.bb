SUMMARY = "Secure Key storage install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/secure-key-storage:"

inherit systemd

SYSTEMD_PACKAGES = "${PN}-load"
SYSTEMD_SERVICE:${PN}-load = "physecurekeystorage-load.service"

SRC_URI = " \
    file://physecurekeystorage-install.sh \
    file://physecurekeystorage-load.service \
"

S = "${UNPACKDIR}"

PACKAGES = "${PN}-install ${PN}-load"

CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"

do_patch() {
    sed -i \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    ${S}/physecurekeystorage-install.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 ${S}/physecurekeystorage-install.sh ${D}${bindir}/physecurekeystorage-install
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/physecurekeystorage-load.service ${D}${systemd_system_unitdir}
}

FILES:${PN}-install = "\
    ${bindir}/physecurekeystorage-install \
"
FILES:${PN}-load = "\
    ${systemd_system_unitdir}/physecurekeystorage-load.service \
"

RDEPENDS:${PN}-install = " \
    jq \
    kernel-module-trusted \
    kernel-module-encrypted-keys \
    keyutils \
    ${@bb.utils.contains("MACHINE_FEATURES", "caam", "keyctl-caam", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "tpm2-tools", "", d)} \
"
RDEPENDS:${PN}-load = "${PN}-install"
