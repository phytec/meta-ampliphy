# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Minimal container image"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

IMAGE_CLASSES += "image_type_docker"
IMAGE_FSTYPES = "docker"

DOCKER_IMAGE_NAME_EXPORT ?= "${PN}:${PV}-${DISTRO_VERSION}"

inherit core-image

IMAGE_INSTALL += " \
    packagegroup-core-container \
    busybox \
    base-passwd \
    netbase \
"
