# Copyright (C) 2015 PHYTEC Messtechnik GmbH
# Author: Stefan Müller-Klieser <s.mueller-klieser@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = ""
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    kernel-module-mtd-nandecctest \
    kernel-module-mtd-subpagetest \
    kernel-module-mtd-torturetest \
    kernel-module-mtd-pagetest \
    kernel-module-mtd-stresstest \
    kernel-module-mtd-oobtest \
    kernel-module-mtd-readtest \
    kernel-module-mtd-speedtest \
    kernel-module-mtd-nandbiterrs \
"
