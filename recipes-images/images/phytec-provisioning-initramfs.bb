SUMMARY = "PHYTEC provisioning initramfs image for initialization of security features on the device"
LICENSE = "MIT"

inherit core-image image_types
require recipes-images/images/security/setrootpassword.inc

# Do not pollute the initrd image with rootfs features
IMAGE_FEATURES = ""
IMAGE_LINGUAS = ""

IMAGE_ROOTFS_SIZE = "8192"
IMAGE_ROOTFS_EXTRA_SPACE = "0"
IMAGE_OVERHEAD_FACTOR = "1.0"

IMAGE_FSTYPES = "cpio.gz"
export IMAGE_BASENAME = "phytec-provisioning-initramfs"
IMAGE_NAME_SUFFIX = ""

IMAGE_INSTALL:remove:mx8m-nxp-bsp = "packagegroup-fsl-optee-imx"
MACHINE_FIRMWARE:remove:mx8mp-nxp-bsp  = "sof-imx sof-zephyr zephyr-demo-imx"

IMAGE_INSTALL = " \
    initramfs-framework-base \
    initramfs-module-udev \
    initramfs-module-provisioninginit \
    initramfs-module-network \
    initramfs-module-timesync \
    initramfs-module-smartcard \
    ${@bb.utils.contains("MACHINE_FEATURES", "optee", "initramfs-module-optee", "", d)} \
    busybox \
    packagegroup-hwtools-init \
    util-linux \
    coreutils \
    ${MACHINE_EXTRA_RDEPENDS} \
    phyprovisoning-emmc \
    physecurekeystorage-install \
    packagegroup-sks-kernelkeyring \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "packagegroup-secure-storage", "", d)} \
    ${@bb.utils.contains("DISTRO_FEATURES", "securestorage", "physecurestorage-install", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis-spi", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "kernel-module-tpm-tis",   "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-pkcs11-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-openssl-tpm2", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "packagegroup-sks-provision-tpm2", "", d)} \
    packagegroup-cryptodev \
    rng-tools \
    pv \
    systemd-conf \
"

IMAGE_INSTALL:append:mx8m-generic-bsp = " ${MACHINE_FIRMWARE} kernel-module-imx-sdma"

IMAGE_INSTALL:remove:mx8m-nxp-bsp = " \
    kernel-module-tpm-tis-spi \
    kernel-module-tpm-tis \
"

IMAGE_INSTALL:append:imx-generic-bsp = " crucible"

PACKAGE_EXCLUDE = "kernel-image-*"

# Remove some packages added via recommendations
BAD_RECOMMENDATIONS += " \
    initramfs-module-rootfs \
    initramfs-module-finish \
    busybox-syslog \
"
