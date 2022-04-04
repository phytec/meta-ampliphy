SUMMARY = "Provisioning eMMC install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/provisioning:"
SRC_URI = " \
    file://phyprovisioning-install-emmc.sh \
"

S = "${WORKDIR}"

SKS_PATH ??= "/dev/mmcblk${EMMC_DEV}p1"
SKS_MOUNTPATH ??= "/mnt_secrets"
SKS_SECRETFOLDER ??= "/secrets"

do_patch() {
    sed -i \
    -e 's:@SKS_PATH@:${SKS_PATH}:g' \
    -e 's:@SKS_MOUNTPATH@:${SKS_MOUNTPATH}:g' \
    -e 's:@SKS_SECRETFOLDER@:${SKS_SECRETFOLDER}:g' \
    ${WORKDIR}/phyprovisioning-install-emmc.sh
}

do_install() {
    install -d ${D}${bindir}
    install -m 0500 phyprovisioning-install-emmc.sh ${D}${bindir}/phyprovisioning-install-emmc
}

FILES:${PN} = "\
    ${bindir}/phyprovisioning-install-emmc \
"
