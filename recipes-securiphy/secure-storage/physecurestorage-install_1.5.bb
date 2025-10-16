SUMMARY = "Secure storage install file integrity and encryption"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/secure-storage:"
SRC_URI = " \
    file://physecurestorage-install.sh \
"

S = "${UNPACKDIR}"

FLASH_PATH ??= "/dev/mmcblk${EMMC_DEV}"

do_patch() {
    sed -i \
    -e 's:@FLASH_PATH@:${FLASH_PATH}:g' \
    ${S}/physecurestorage-install.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 ${S}/physecurestorage-install.sh ${D}${bindir}/physecurestorage-install
}

RDEPENDS:${PN} = " \
    xz \
"

FILES:${PN} = "\
    ${bindir}/physecurestorage-install \
"
