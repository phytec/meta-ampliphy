SUMMARY = "Phytec's FIT-Image without ramdisk"
DESCRIPTION = "FIT-Image with one Kernel and one devicetree"
LICENSE = "MIT"
require phytec-fitimage-base.inc

FITIMAGE_SLOTS ?= "kernel fdt fdto"
