SUMMARY = "PHYTEC rauc bundles from meta-yogurt"
HOMEPAGE = "http://www.phytec.de"

DEP_BOOTLOADER = "${@bootloader_dependencies(d)}"
DEPENDS += "phytec-dev-ca-native ${DEP_BOOTLOADER}"
do_bundle[depends] += "phytec-dev-ca-native:do_install"
do_emmc_boot[depends] += "${DEP_BOOTLOADER}:do_deploy"

inherit bundle

RAUC_BUNDLE_DESCRIPTION ?= "PHYTEC rauc bundle based on ${DISTRO_VERSION}"

RAUC_BUNDLE_COMPATIBLE ?= "${MACHINE}"

RAUC_BUNDLE_SLOTS ?= " \
    rootfs \
    ${@bb.utils.contains('MACHINE_FEATURES','emmc','boot bootloader','kernel dtb', d)} \
"

RAUC_SLOT_rootfs[type] ?= "image"
RAUC_IMAGE_FSTYPE ?= "${@bb.utils.contains('MACHINE_FEATURES','emmc','tar.gz','ubifs', d)}"

RAUC_SLOT_kernel ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_kernel[type] ?= "kernel"

RAUC_SLOT_bootloader ?= "${PREFERRED_PROVIDER_virtual/bootloader}"
RAUC_SLOT_bootloader[type] ?= "boot"
RAUC_SLOT_bootloader[file] ?= "emmc-boot.img"

RAUC_SLOT_dtb ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_dtb[type] ?= "file"
RAUC_SLOT_dtb[file] ?= "${@first_dtb(d)}"
def first_dtb(d):
    dtbs = d.getVar('KERNEL_DEVICETREE')
    return dtbs.split()[0]

RAUC_SLOT_boot ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_boot[type] ?= "file"
RAUC_SLOT_boot[file] ?= "boot.tar.gz"

# Here we need to use the "imx-boot" image because it contains the bootloader and
# other binaries instead of the sole bootloader "u-boot-imx".
def bootloader_dependencies(d):
    if d.expand("${PREFERRED_PROVIDER_virtual/bootloader}") == "u-boot-imx":
        return "imx-boot"
    else:
        return d.expand("${PREFERRED_PROVIDER_virtual/bootloader}")

python do_unpack_prepend() {
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
}

python do_unpack_append() {
    if os.path.isfile("%s/boot.tar.gz" % deploy_dir):
        os.remove("%s/boot.tar.gz" % deploy_dir)
}

python do_emmc_boot() {
    import subprocess

    create_img = {
        "u-boot-imx": ["dd", d.expand("if=${DEPLOY_DIR_IMAGE}/imx-boot"),
                       d.expand("of=${DEPLOY_DIR_IMAGE}/emmc-boot.img"),
                       "bs=1k", "seek=33"],
        "barebox": ["ln", "-sf", "barebox.bin",
                    d.expand("${DEPLOY_DIR_IMAGE}/emmc-boot.img")]
    }
    if "emmc" in d.expand("${MACHINE_FEATURES}"):
        subprocess.call(create_img[d.expand("${PREFERRED_PROVIDER_virtual/bootloader}")])
}

addtask emmc_boot after do_fetch before do_unpack

do_deploy_append() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${WORKDIR}/archives/${IMAGE_NAME}.boot.tar.gz ${DEPLOYDIR}/${IMAGE_NAME}.boot.tar.gz
    ln -sf ${IMAGE_NAME}.boot.tar.gz ${DEPLOYDIR}/boot.tar.gz
}

RAUC_KEY_FILE ?= "${CERT_PATH}/rauc/private/development-1.key.pem"
RAUC_CERT_FILE ?= "${CERT_PATH}/rauc/development-1.cert.pem"
BUNDLE_ARGS += " --intermediate=${CERT_PATH}/rauc/ca.cert.pem"
