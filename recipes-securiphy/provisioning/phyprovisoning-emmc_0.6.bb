SUMMARY = "Provisioning eMMC install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/provisioning:"
SRC_URI = " \
    file://phyprovisioning-install-emmc.sh \
"

S = "${UNPACKDIR}"

SKS_PATH ??= "/dev/mmcblk${EMMC_DEV}p1"
SKS_MOUNTPATH ??= "/mnt_secrets"
SKS_SECRETFOLDER ??= "/secrets"
CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"
CONFIG_BOOTDEV ??= "mmcblk${EMMC_DEV}boot0"

do_patch() {
    sed -i \
    -e 's:@SKS_PATH@:${SKS_PATH}:g' \
    -e 's:@SKS_MOUNTPATH@:${SKS_MOUNTPATH}:g' \
    -e 's:@SKS_SECRETFOLDER@:${SKS_SECRETFOLDER}:g' \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    -e 's:@CONFIG_BOOTDEV@:${CONFIG_BOOTDEV}:g' \
    ${WORKDIR}/phyprovisioning-install-emmc.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 phyprovisioning-install-emmc.sh ${D}${bindir}/phyprovisioning-install-emmc
}

RDEPENDS:${PN} = " \
    partup \
"

FILES:${PN} = "\
    ${bindir}/phyprovisioning-install-emmc \
"
