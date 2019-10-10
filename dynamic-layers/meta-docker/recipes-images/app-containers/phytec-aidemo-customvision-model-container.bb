# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Custom Vision model runner container"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

require ../base-containers/phytec-python-container.bb

PV = "0.5.0"
DOCKER_IMAGE_NAME_EXPORT = "${PN}:${PV}-${DISTRO_VERSION}"

IMAGE_INSTALL += "aidemo-customvision-model"
