FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:mx95-generic-bsp += " \
    file://0001-ipa-nxp-Add-simple-camera-helper-for-phycams.patch \
    file://0002-ipa-nxp-neo-Add-simple-isp-config-for-phycams.patch \
    file://0003-ipa-nxp-neo-Add-small-fixes.patch \
    file://0004-libcamera-libipa-camera_sensor-Add-sensor-properties.patch \
    file://0001-gstreamer-Add-raw-support-to-libcamerasrc-stream-rol.patch \
    file://0002-camera_sensor_legacy-Allow-to-replace-ANALOGUE_GAIN-.patch \
    file://0003-libcamera-libipa-camera_sensor-Add-sensor-properties.patch \
    file://0004-ipa-nxp-neo-Add-simple-isp-config-for-ar0830.patch \
    file://0005-ipa-nxp-Add-simple-camera-helper-for-VM-024-phyCAM.patch \
"

