SUMMARY = "Secure Key storage install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/secure-key-storage:"
SRC_URI = " \
    file://physecurekeystorage-install.sh \
"

S = "${UNPACKDIR}"

CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"

do_patch() {
    sed -i \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    ${WORKDIR}/physecurekeystorage-install.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 physecurekeystorage-install.sh ${D}${bindir}/physecurekeystorage-install
}

FILES:${PN} = "\
    ${bindir}/physecurekeystorage-install \
"

RDEPENDS:${PN} = " \
    jq \
"
