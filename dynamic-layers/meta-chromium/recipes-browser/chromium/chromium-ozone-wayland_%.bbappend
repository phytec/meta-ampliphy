DEPENDS += "\
    icu-native \
"

GN_ARGS += " \
    use_system_icu=true \
    icu_use_data_file=true \
"

SRC_URI:append:ti-soc = " \
                  file://0001-chromium-gpu-sandbox-allow-access-to-PowerVR-GPU-fro.patch \
                  "
