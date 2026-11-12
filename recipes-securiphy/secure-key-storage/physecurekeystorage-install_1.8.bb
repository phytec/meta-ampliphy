SUMMARY = "Secure Key storage install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

CVE_PRODUCT = "phytec:${BPN}"

FILESEXTRAPATHS:prepend := "${THISDIR}/secure-key-storage:"
SRC_URI = " \
    file://physecurekeystorage-install.sh \
"

S = "${WORKDIR}"

CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"
ENCRYPTED_KEY_LABEL ??= "encrypted_key.blob"
TRUSTED_KEY_LABEL ??= "trusted_key.blob"
TRUSTED_TYPE_LABEL ??= "trusted_key.config"
OPTEE_TRUSTED_SLOT ??= "0"
OPTEE_TRUSTED_TOKEN_NAME ??= "keyblobs_store"
OPTEE_TRUSTED_SO_PIN_LABEL ??= "so_pin"
OPTEE_TRUSTED_USER_PIN_LABEL ??= "user_pin"

do_patch() {
    sed -i \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    -e 's:@ENCRYPTED_KEY_LABEL@:${ENCRYPTED_KEY_LABEL}:g' \
    -e 's:@TRUSTED_KEY_LABEL@:${TRUSTED_KEY_LABEL}:g' \
    -e 's:@TRUSTED_TYPE_LABEL@:${TRUSTED_TYPE_LABEL}:g' \
    -e 's:@OPTEE_TRUSTED_SLOT@:${OPTEE_TRUSTED_SLOT}:g' \
    -e 's:@OPTEE_TRUSTED_TOKEN_NAME@:${OPTEE_TRUSTED_TOKEN_NAME}:g' \
    -e 's:@OPTEE_TRUSTED_SO_PIN_LABEL@:${OPTEE_TRUSTED_SO_PIN_LABEL}:g' \
    -e 's:@OPTEE_TRUSTED_USER_PIN_LABEL@:${OPTEE_TRUSTED_USER_PIN_LABEL}:g' \
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
