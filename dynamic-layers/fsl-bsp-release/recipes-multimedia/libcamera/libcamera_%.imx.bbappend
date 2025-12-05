FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:mx95-generic-bsp += " \
    file://0001-ipa-nxp-Add-simple-camera-helper-for-phycams.patch \
    file://0002-ipa-nxp-neo-Add-simple-isp-config-for-phycams.patch \
    file://0003-ipa-nxp-neo-Add-small-fixes.patch \
    file://0004-libcamera-libipa-camera_sensor-Add-sensor-properties.patch \
"

