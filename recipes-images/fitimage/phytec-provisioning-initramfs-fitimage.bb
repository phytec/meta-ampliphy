SUMMARY = "Phytec's FIT-Image with provisioning"
DESCRIPTION = "FIT-Image with a single kernel, devicetree and provisioning ramdisk"
LICENSE = "MIT"

require phytec-fitimage-base.inc

FITIMAGE_SLOTS ?= "kernel fdt fdto ramdisk"

FITIMAGE_SLOT_ramdisk ?= "phytec-provisioning-initramfs"
FITIMAGE_SLOT_ramdisk[type] ?= "ramdisk"
FITIMAGE_SLOT_ramdisk[fstype] ?= "cpio.gz"
