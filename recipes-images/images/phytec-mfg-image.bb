SUMMARY = "Phytec's manufacturing image"
DESCRIPTION = "Image being flashed during manufacturing"
LICENSE = "MIT"

IMAGE_LINGUAS = ""
IMAGE_FEATURES = ""
IMAGE_INSTALL = ""
PACKAGE_INSTALL = ""

IMAGE_CLASSES += "image-types-partup"
IMAGE_FSTYPES = "partup"

inherit core-image

PARTUP_SECTION_partitions = "0"

PARTUP_PACKAGE_FILES = "${BOOTLOADER_FILE}"
PARTUP_PACKAGE_FILES:k3 = "${K3_BOOTLOADER_FILES}"

PARTUP_PACKAGE_DEPENDS = "virtual/bootloader"

NO_RECOMMENDATIONS = "1"
