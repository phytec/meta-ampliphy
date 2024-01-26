SUMMARY = "PHYTEC rauc bundles from meta-ampliphy"
HOMEPAGE = "http://www.phytec.de"

DEP_BOOTLOADER ?= "${PREFERRED_PROVIDER_virtual/bootloader}"
DEP_BOOTLOADER:mx8-nxp-bsp = "${IMAGE_BOOTLOADER}"
DEP_BOOTLOADER:mx93-nxp-bsp = "${IMAGE_BOOTLOADER}"
do_bundle[depends] += "phytec-dev-ca-native:do_install"
do_emmc_boot[depends] += "${DEP_BOOTLOADER}:do_deploy"

inherit bundle image-artifact-names

DEPENDS += "phytec-dev-ca-native ${DEP_BOOTLOADER} libp11-native"
RAUC_BUNDLE_DESCRIPTION ?= "PHYTEC rauc bundle based on ${DISTRO_VERSION}"

RAUC_BUNDLE_FORMAT ?= "verity"
RAUC_BUNDLE_COMPATIBLE ?= "${MACHINE}"

RAUC_BUNDLE_SLOTS ?= " \
    rootfs \
    ${@bb.utils.contains('MACHINE_FEATURES','emmc','boot bootloader','kernel dtb', d)} \
"

RAUC_SLOT_rootfs[type] ?= "image"
RAUC_SLOT_rootfs[adaptive] ?= "block-hash-index"
RAUC_IMAGE_FSTYPE ?= "${@bb.utils.contains('MACHINE_FEATURES','emmc','ext4','ubifs', d)}"

RAUC_SLOT_kernel ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_kernel[file] ?= "${KERNEL_IMAGETYPE}"
RAUC_SLOT_kernel[type] ?= "kernel"

RAUC_SLOT_bootloader ?= "${PREFERRED_PROVIDER_virtual/bootloader}"
RAUC_SLOT_bootloader[type] ?= "boot"
RAUC_SLOT_bootloader[file] ?= "emmc-boot.img"
RAUC_SLOT_bootloader[offset] ?= "${BOOTLOADER_SEEK_EMMC}K"

RAUC_SLOT_dtb ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_dtb[type] ?= "file"
RAUC_SLOT_dtb[file] ?= "${@first_dtb(d)}"
def first_dtb(d):
    dtbs = d.getVar('KERNEL_DEVICETREE')
    return dtbs.split()[0]

RAUC_SLOT_boot ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_boot[type] ?= "boot"
RAUC_SLOT_boot[file] ?= "boot.tar.gz"

python do_configure:prepend() {
    import shutil
    import subprocess
    import os

    ibfs = d.expand("${IMAGE_BOOT_FILES}")
    archives_dir = d.expand("${WORKDIR}/archives")
    boot_dir = "%s/boot" % archives_dir
    deploy_dir = d.expand("${DEPLOY_DIR_IMAGE}")

    if os.path.lexists(boot_dir):
        shutil.rmtree(boot_dir)

    os.makedirs(boot_dir)

    for files in ibfs.split():
        src = files.split(";")[0]
        dst = "{}/{}".format(boot_dir, files.split(";")[-1])

        if src[0] == "/":
            shutil.copy(src, dst)
        else:
            shutil.copy(d.expand("%s/%s" % (deploy_dir, src)), dst)

    tarfile = d.expand("${IMAGE_NAME}.boot.tar.gz")
    tarpath = "%s/%s" % (archives_dir, tarfile)
    subprocess.call(["tar", "-czhf", tarpath, "-C", boot_dir, ".",
            "--owner=0", "--group=0"])

    if os.path.islink("%s/boot.tar.gz" % deploy_dir):
        os.remove("%s/boot.tar.gz" % deploy_dir)
    os.symlink(tarpath, "%s/boot.tar.gz" % deploy_dir)

    # Create link to eMMC bootloader image with correct image type
    bootloader_filename = {
        "barebox": d.getVar("BAREBOX_BINARY"),
        "u-boot-imx": "u-boot.imx",
        "imx-boot": "imx-boot",
        "u-boot-ti": "u-boot.img"
    }
    emmc_boot_path = "%s/%s" % (deploy_dir, "emmc-boot.img")
    if os.path.islink(emmc_boot_path):
        os.remove(emmc_boot_path)
    os.symlink(bootloader_filename[d.getVar("DEP_BOOTLOADER")], emmc_boot_path)
}

python do_configure:append() {
    if os.path.isfile("%s/boot.tar.gz" % deploy_dir):
        os.remove("%s/boot.tar.gz" % deploy_dir)
}

do_bundle:prepend() {
        # Workaround: Sets OPENSSL_ENGINES env var, so openssl library does not search in its own sysroot for engines,
        # but rather in the sysroot of the recipe using do_bundle()

        # dir name depends on the version, so best to extract it from openssl
        engines_dir=`basename $( openssl version -e | sed -e 's/.*"\(.*\)".*/\1/g')`
        export OPENSSL_ENGINES="${WORKDIR}/recipe-sysroot-native/usr/lib/${engines_dir}"
        if [ -n "${RAUC_PKCS11_MODULE}" ] ; then
            export RAUC_PKCS11_MODULE="${RAUC_PKCS11_MODULE}"
        fi
}

do_deploy:append() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/archives/${IMAGE_NAME}.boot.tar.gz ${DEPLOYDIR}/${IMAGE_NAME}.boot.tar.gz
    ln -sf ${IMAGE_NAME}.boot.tar.gz ${DEPLOYDIR}/boot.tar.gz
}

RAUC_KEY_FILE ?= "${CERT_PATH}/rauc-intermediate/private/development-1.key.pem"
RAUC_CERT_FILE ?= "${CERT_PATH}/rauc-intermediate/development-1.cert.pem"
RAUC_KEYRING_FILE ?= "${CERT_PATH}/main-ca/mainca-rsa.crt.pem"
BUNDLE_ARGS += "--intermediate=${CERT_PATH}/rauc-intermediate/ca.cert.pem"
CONVERT_ARGS += "--intermediate=${CERT_PATH}/rauc-intermediate/ca.cert.pem"
