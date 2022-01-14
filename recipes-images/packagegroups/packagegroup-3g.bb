DESCRIPTION = "Cellular data tools used on Phytec boards"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    modemmanager \
    kernel-module-cdc-acm \
    kernel-module-cdc-ether \
    kernel-module-cdc-mbim \
    kernel-module-cdc-ncm \
    kernel-module-cdc-wdm \
"
