SUMMARY = "Phytecs hardware testing image"
DESCRIPTION = "A small image capable of allowing a device to boot and \
               check for hardware problems."
LICENSE = "MIT"

require phytec-headless-image.bb

IMAGE_INSTALL += " \
    ${MTD_TEST_PACKAGES} \
"
