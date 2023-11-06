# Copyright (C) 2023 Leonard Anderweit <l.anderweit@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Script to check kernel config for virtualization"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://LICENSE;md5=435b266b3899aa8a959f17d41c56def8"

SRCREV = "26a98ea20ee1e946f07fc8a9ba9f11b84b39e4a0"
SRC_URI = "git://github.com/opencontainers/runc;branch=release-1.1;protocol=https"

S = "${WORKDIR}/git"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install () {
    install -D -m 0755 ${S}/script/check-config.sh ${D}${bindir}/check-config.sh
}
