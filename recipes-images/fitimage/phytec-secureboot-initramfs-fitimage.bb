SUMMARY = "Phytec's FIT-Image with secureboot initramfs"
DESCRIPTION = "FIT-Image with a single kernel, devicetree and secureboot ramdisk"
LICENSE = "MIT"

require phytec-fitimage-base.inc

FITIMAGE_SLOTS ?= "kernel fdt fdto ramdisk"
FITIMAGE_SLOTS:phyboard-mira-imx6 ?= "kernel fdt fdtadin1300 fdtksz9131 ramdisk"
FITIMAGE_SLOTS:phyboard-nunki-imx6 ?= "kernel fdt fdtadin1300 fdtksz9131 ramdisk"
FITIMAGE_SLOTS:mx6ul-generic-bsp ?= "kernel fdt fdto ramdisk ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'tee', '', d )}"

FITIMAGE_SLOT_ramdisk ?= "phytec-secureboot-initramfs"
FITIMAGE_SLOT_ramdisk[type] ?= "ramdisk"
FITIMAGE_SLOT_ramdisk[fstype] ?= "cpio.gz"
