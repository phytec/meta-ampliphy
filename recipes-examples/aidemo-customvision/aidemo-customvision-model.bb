# Copyright (C) 2019 Martin Schwan <m.schwan@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

SUMMARY = "Custom Vision model runner"
HOMEPAGE = "https://www.phytec.de"

LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://../../LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"

SRC_URI = "git://git.phytec.de/aidemo-customvision"
SRCREV = "239a7a47c5e01030d958967c773b1f6f54408c5d"
S = "${WORKDIR}/git/modules/model"

inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
    mkdir -p ${D}${datadir}/${BPN}
    cp -R --no-dereference --preserve=mode,links -v ${S}/* ${D}${datadir}/${BPN}
}

RDEPENDS_${PN} += " \
    tensorflow \
    opencv \
    python3-pillow \
    python3-flask \
    python3-waitress \
"
FILES_${PN} = "${datadir}/${BPN}"
INSANE_SKIP_${PN} = "file-rdeps"
