SUMMARY = "Phytec's container image"
DESCRIPTION = "container support with podman with this image"
LICENSE = "MIT"

require recipes-images/images/phytec-headless-image.bb
inherit features_check

REQUIRED_DISTRO_FEATURES = "virtualization"

IMAGE_INSTALL += " \
    packagegroup-virtualization \
"
