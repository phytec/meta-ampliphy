inherit features_check
require phytec-base-bundle.inc

REQUIRED_DISTRO_FEATURES = "secureboot"

RAUC_SLOT_rootfs ?= "phytec-securiphy-image"
