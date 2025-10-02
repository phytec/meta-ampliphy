SUMMARY = "Phytec's SPI-NOR flash image"
DESCRIPTION = "Minimal image used for SPI-NOR flash devices only"
LICENSE = "MIT"

IMAGE_LINGUAS = ""

PACKAGE_INSTALL = ""
IMAGE_INSTALL = ""

IMAGE_CLASSES += "image-types-partup"
IMAGE_FSTYPES = "partup"

inherit core-image

PARTUP_LAYOUT_CONFIG ??= ""
PARTUP_LAYOUT_CONFIG:mx8-generic-bsp = "spi-nor-imx8.yaml"
PARTUP_LAYOUT_CONFIG:k3 = "spi-nor-k3.yaml"

PARTUP_PACKAGE_FILES = "${BOOTLOADER_FILE}"
PARTUP_PACKAGE_FILES:k3 = "${K3_BOOTLOADER_FILES}"
