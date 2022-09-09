SUMMARY = "Phytec's FIT-Image with secureboot ramdisk"
DESCRIPTION = "FIT-Image with a single kernel, devicetree and secureboot ramdisk"
LICENSE = "MIT"

require phytec-fitimage-base.inc

FITIMAGE_SLOTS ?= "kernel fdt fdto ramdisk"
FITIMAGE_SLOTS:phyboard-mira-imx6 ?= "kernel fdt fdtapply ramdisk"
FITIMAGE_SLOTS:phyboard-nunki-imx6 ?= "kernel fdt fdtapply ramdisk"

FITIMAGE_SLOT_ramdisk ?= "phytec-secureboot-ramdisk-image"
FITIMAGE_SLOT_ramdisk[type] ?= "ramdisk"
FITIMAGE_SLOT_ramdisk[fstype] ?= "cpio.gz"
