FILESEXTRAPATHS:prepend := "${CERT_PATH}/rauc:"
FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

DEPENDS += "phytec-dev-ca-native config-partition"
do_fetch[depends] += "phytec-dev-ca-native:do_install"

# set path to the rauc keyring, which is installed in the image
RAUC_KEYRING_FILE ?= "mainca-rsa.crt.pem"
RAUC_KEYRING_FILE_DEVICE_PATH ?= "${@os.path.basename(d.getVar("RAUC_KEYRING_FILE"))}"

SRC_URI += " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'file://system_emmc.conf', 'file://system_nand.conf', d)} \
"

PACKAGE_ARCH = "${MACHINE_ARCH}"

# Default eMMC and raw NAND device used in the system.conf. These variables must
# be set in the machine configuration.
EMMC_DEV ??= "0"
NAND_DEV ??= "0"

ROOTFS_0_DEV ??= "/dev/mmcblk${EMMC_DEV}p5"
ROOTFS_1_DEV ??= "/dev/mmcblk${EMMC_DEV}p6"
ROOTFS_0_DEV:fileauthorenc ?= "/dev/dm-0"
ROOTFS_1_DEV:fileauthorenc ?= "/dev/dm-1"
ROOTFS_0_DEV:fileauthandenc ?= "/dev/dm-1"
ROOTFS_1_DEV:fileauthandenc ?= "/dev/dm-3"

USE_BOOTLOADER_SLOT ?= "${USE_BOOTLOADER_SLOT_WEAK_DEFAULT}"
# we don't use overrides directly to set a default, as this cannot be
# overridden by normal assignment later on
USE_BOOTLOADER_SLOT_WEAK_DEFAULT = "true"
USE_BOOTLOADER_SLOT_WEAK_DEFAULT:ti33x = "false"
USE_BOOTLOADER_SLOT_WEAK_DEFAULT:rk3288 = "false"

# We want system.conf to be fetched before any of the following variables are
# changed. This is needed because ${WORKDIR}/system.conf is overridden by
# system_{emmc,nand}.conf and parsed using these variables afterwards. The
# parsing, however, does not do anything unless the template
# system_{emmc,nand}.conf is copied over before it, which only happens if the
# default system.conf exists in WORKDIR.
do_fetch[vardeps] += " \
    PREFERRED_PROVIDER_virtual/bootloader \
    EMMC_DEV \
    NAND_DEV \
    ROOTFS_0_DEV \
    ROOTFS_1_DEV \
    RAUC_KEYRING_FILE \
    USE_BOOTLOADER_SLOT \
"

# Returns the correct string for the key "bootloader" used in RAUC's system.conf
# depending on the currently set bootloader in Yocto. See
# https://rauc.readthedocs.io/en/latest/reference.html#system-section for all
# supported values.
def map_system_conf_bootloader(d):
    bootloader_map = {
        "barebox": "barebox",
        "u-boot": "uboot",
        "u-boot-imx": "uboot",
        "u-boot-phytec": "uboot",
        "u-boot-ti": "uboot"
    }
    bootloader = d.getVar("PREFERRED_PROVIDER_virtual/bootloader")
    if bootloader not in bootloader_map:
        bb.warn("Unsupported or no PREFERRED_PROVIDER selected for virtual/bootloader, rauc will not work correctly.")
        return "noop"
    else:
        return bootloader_map[bootloader]

do_install:prepend() {
    cp ${WORKDIR}/${@bb.utils.contains('MACHINE_FEATURES', 'emmc', 'system_emmc.conf', 'system_nand.conf', d)} ${WORKDIR}/system.conf
    sed -i \
        -e 's/@MACHINE@/${MACHINE}/g' \
        -e 's/@BOOTLOADER@/${@map_system_conf_bootloader(d)}/g' \
        -e 's/@EMMC_DEV@/${EMMC_DEV}/g' \
        -e 's/@NAND_DEV@/${NAND_DEV}/g' \
        -e 's!@ROOTFS_0_DEV@!${ROOTFS_0_DEV}!g' \
        -e 's!@ROOTFS_1_DEV@!${ROOTFS_1_DEV}!g' \
        -e 's!@RAUC_KEYRING_FILE@!${RAUC_KEYRING_FILE_DEVICE_PATH}!g' \
        ${@bb.utils.contains("USE_BOOTLOADER_SLOT", "true", "", "-e '/@IF_BOOTLOADER_SLOT@/,/@ENDIF_BOOTLOADER_SLOT@/d'", d)} \
        ${@bb.utils.contains("DISTRO_FEATURES", "rauc-appfs", "", "-e '/@IF_APPFS_SLOT@/,/@ENDIF_APPFS_SLOT@/d'", d)} \
        -e '/@\(IF\|ENDIF\)[A-Z_]\+@/d' \
        ${WORKDIR}/system.conf

	# check for problematic certificate setups
	shasum=$(sha256sum "${WORKDIR}/${RAUC_KEYRING_FILE}" | cut -d' ' -f1)
	if [ "$shasum" = "91efd86dfbffa360c909b06b54902348075c5ba7902ad1ec30d25527a1f8ca09" ]; then
		bbwarn "You're including Phytec's Development Keyring in the rauc bundle. Please create your own!"
	fi
}
