DESCRIPTION = "3g tools used on Phytec boards"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    ofono \
    ofono-tests \
    modemmanager \
    kernel-module-cdc-acm \
    kernel-module-cdc-ether \
    kernel-module-cdc-mbim \
    kernel-module-cdc-ncm \
    kernel-module-cdc-wdm \
"
