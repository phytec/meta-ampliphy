# Copyright (C) 2020 PHYTEC Messtechnik GmbH,
# Author: Maik Otto <m.otto@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "secureboot ramdisk required files for file encryption"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
SRC_URI = " \
    file://secureboot-fileencrypt.sh \
"

S = "${WORKDIR}"

do_install() {
    install -m 0755 secureboot-fileencrypt.sh ${D}/init
}

# Do not create debug/devel packages
PACKAGES = "${PN}"

FILES:${PN} = "/"

# Runtime packages used in 'secureboot-ramdisk-init'
RDEPENDS:${PN} = " \
    keyutils \
    util-linux \
    mtd-utils-ubifs \
    e2fsprogs \
    fscryptctl \
    cryptsetup \
    lvm2 \
"

RDEPENDS:${PN}:append:mx8 = " keyctl-caam"
