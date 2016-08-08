# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Stefan Christ <s.christ@phytec.de>

# The mtd test packages are used in
#    recipes-kernel/linux/linux-common-append.inc and
#    recipes-images/images/phytec-hwtest-image.bb
MTD_TEST_PACKAGES = " \
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
