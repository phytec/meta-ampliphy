# Copyright (C) 2018 Daniel Schultz <d.schultz@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Update tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS_${PN} += " \
    rauc \
    rauc-hawkbit \
"
