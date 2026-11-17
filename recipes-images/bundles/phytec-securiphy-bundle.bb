inherit features_check
require phytec-base-bundle.inc

REQUIRED_DISTRO_FEATURES = "secureboot"

RAUC_SLOT_rootfs ?= "phytec-securiphy-image"

# On NAND, the bootloader only boots the signed FIT image from the kernel slot
RAUC_SLOT_kernel:mx6-generic-bsp = "linux-yocto-fitimage"
RAUC_SLOT_kernel:mx6ul-generic-bsp = "phytec-simple-fitimage"
RAUC_SLOT_kernel[file] = "fitImage"
