SUMMARY = "securestorage ramdisk required files for file authentication and encryption"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/provisioning:"

SRC_URI = " \
    file://provisioning-init.sh \
"

# be set in the machine configuration.
SKS_PATH ??= "/dev/mmcblk${EMMC_DEV}p1"
SKS_MOUNTPATH ??= "/mnt_secrets"

S = "${WORKDIR}"

do_patch() {
    sed -i \
    -e 's:@SKS_PATH@:${SKS_PATH}:g' \
    -e 's:@SKS_MOUNTPATH@:${SKS_MOUNTPATH}:g' \
    ${WORKDIR}/provisioning-init.sh
}

do_install() {
    install -m 0755 provisioning-init.sh ${D}/init
}

# Do not create debug/devel packages
PACKAGES = "${PN}"

FILES_${PN} = "/"
