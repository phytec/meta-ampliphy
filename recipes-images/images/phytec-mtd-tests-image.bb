# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>

SUMMARY = "Phytecs mtd testing image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
               the mtd test kernel modules are installed."
LICENSE = "MIT"

require phytec-hwbringup-image.bb

# Variable MTD_TEST_PACKAGES is defined in conf/layer.conf.
IMAGE_INSTALL += "${MTD_TEST_PACKAGES}"
