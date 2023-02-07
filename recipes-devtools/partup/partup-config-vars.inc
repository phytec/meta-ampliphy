SRC_URI_append = " \
    file://simple.yaml \
    file://rauc-ab.yaml \
"

PARTUP_API_VERSION = "${@d.getVar('PV').split('.')[0]}"

DISKLABEL ??= "msdos"

BOOTLOADER_URI ??= ""
BOOTLOADER_URI_mx6 ?= "barebox.bin"
BOOTLOADER_URI_mx8 ?= "imx-boot"

KERNEL_URI ??= "${KERNEL_IMAGETYPE}"

DTB_URI ??= "oftree"

CONFIG_URI ??= "config-partition.tar.gz"

ROOTFS_URI ??= "rootfs.ext4"

ROOTFS_TYPE ??= "${@bb.utils.contains('DISKLABEL', 'msdos', 'logical', 'primary', d)}"

EMMC_BOOT_INPUT_OFFSET ??= "0"

EMMC_BOOT_OUTPUT_OFFSET ??= "0"
EMMC_BOOT_OUTPUT_OFFSET_mx8m ?= "33kiB"
EMMC_BOOT_OUTPUT_OFFSET_mx8mn ?= "0"
EMMC_BOOT_OUTPUT_OFFSET_mx8mp ?= "0"

BOOTLOADER_INPUT_OFFSET ??= "0"
BOOTLOADER_INPUT_OFFSET_mx6 ?= "1kiB"

BOOTLOADER_OUTPUT_OFFSET ??= "2kiB"
BOOTLOADER_OUTPUT_OFFSET_mx6 ?= "1kiB"
BOOTLOADER_OUTPUT_OFFSET_mx8m ?= "33kiB"
BOOTLOADER_OUTPUT_OFFSET_mx8mn ?= "32kiB"
BOOTLOADER_OUTPUT_OFFSET_mx8mp ?= "32kiB"

BOOT_SIZE ??= "64MiB"
BOOT_SIZE_mx8 ?= "128MiB"

CONFIG_SIZE ??= "64MiB"

do_fetch[vardeps] += " \
    PARTUP_API_VERSION \
    DISKLABEL \
    BOOTLOADER_URI \
    KERNEL_URI \
    DTB_URI \
    CONFIG_URI \
    ROOTFS_URI \
    EMMC_BOOT_INPUT_OFFSET \
    EMMC_BOOT_OUTPUT_OFFSET \
    BOOTLOADER_INPUT_OFFSET \
    BOOTLOADER_OUTPUT_OFFSET \
    BOOT_SIZE \
    CONFIG_SIZE \
"

python do_patch_append() {
    filenames = [
        'simple.yaml',
        'rauc-ab.yaml'
    ]
    for filename in filenames:
        with open(filename, 'r') as f:
            content = f.read()
            content = d.expand(content)
        with open(filename, 'w') as f:
            f.write(content)
}

do_install_append() {
    install -d ${D}${datadir}/partup
    install -m 644 ${WORKDIR}/simple.yaml ${D}${datadir}/partup/
    install -m 644 ${WORKDIR}/rauc-ab.yaml ${D}${datadir}/partup/
}
