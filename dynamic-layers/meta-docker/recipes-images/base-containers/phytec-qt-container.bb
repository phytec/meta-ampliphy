# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Desktop container image with Weston and Qt"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

IMAGE_CLASSES += "image_type_docker"
IMAGE_FSTYPES = "docker"

DOCKER_IMAGE_NAME_EXPORT ?= "${PN}:${PV}-${DISTRO_VERSION}"

inherit core-image

IMAGE_INSTALL += " \
    weston \
    weston-init \
    packagegroup-base \
    \
    packagegroup-gstreamer \
    gstreamer1.0-plugins-bad \
    \
    qtbase \
    qtmultimedia \
    qtwayland \
    qtquickcontrols2 \
    \
    netbase \
    bash \
"
