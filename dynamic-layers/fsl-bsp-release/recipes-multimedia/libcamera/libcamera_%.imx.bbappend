FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:mx95-generic-bsp += " \
    file://0001-ipa-nxp-Add-simple-camera-helper-for-phycams.patch \
    file://0002-pipeline-nxp-neo-Add-PHYTEC-phyCAM-configs.patch \
    file://0003-ipa-nxp-neo-Add-small-fixes.patch \
    file://0004-ipa-nxp-neo-Add-simple-isp-config-for-phycams.patch \
"

