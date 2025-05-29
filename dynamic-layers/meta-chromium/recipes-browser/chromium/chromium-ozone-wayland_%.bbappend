FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG[icu] = "use_system_icu=true icu_use_data_file=true,,icu icu-native"
PACKAGECONFIG:append = " icu"

SRC_URI:append:ti-soc = " \
                  file://0001-chromium-gpu-sandbox-allow-access-to-PowerVR-GPU-fro.patch \
                  "
