SUMMARY = "Secure storage install file integrity and encryption"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/secure-storage:"

inherit systemd

SYSTEMD_PACKAGES = "${PN}-open"
SYSTEMD_SERVICE:${PN}-open = "physecurestorage-open.service"

SRC_URI = " \
    file://physecurestorage-install.sh \
    file://physecurestorage-open.sh \
    file://physecurestorage-open.service \
"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

PACKAGES = "${PN}-install ${PN}-open"

FLASH_PATH ??= "/dev/mmcblk${EMMC_DEV}"

do_patch() {
    sed -i \
    -e 's:@FLASH_PATH@:${FLASH_PATH}:g' \
    ${S}/physecurestorage-install.sh

    sed -i \
    -e 's:@FLASH_PATH@:${FLASH_PATH}:g' \
    ${S}/physecurestorage-open.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 ${S}/physecurestorage-install.sh ${D}${bindir}/physecurestorage-install
    install -m 0500 ${S}/physecurestorage-open.sh ${D}${bindir}/physecurestorage-open
    install -d ${D}${systemd_system_unitdir}
    install -m 0644 ${S}/physecurestorage-open.service ${D}${systemd_system_unitdir}
}

RDEPENDS:${PN}-install = " \
    cryptsetup \
    e2fsprogs-mke2fs \
    e2fsprogs-resize2fs \
    kernel-module-dm-crypt \
    kernel-module-dm-integrity \
    keyutils \
    libdevmapper \
    xz \
"
RDEPENDS:${PN}-open = " \
    cryptsetup \
    libdevmapper \
    kernel-module-dm-crypt \
    kernel-module-dm-integrity \
    util-linux-blkid \
"

FILES:${PN}-install = "\
    ${bindir}/physecurestorage-install \
"
FILES:${PN}-open = "\
    ${bindir}/physecurestorage-open \
    ${systemd_system_unitdir}/physecurestorage-open.service \
"
