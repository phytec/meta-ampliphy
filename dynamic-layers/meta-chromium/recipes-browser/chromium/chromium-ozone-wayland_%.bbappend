DEPENDS += "\
    icu-native \
"

GN_ARGS += " \
    use_system_icu=true \
    icu_use_data_file=true \
"

CHROMIUM_EXTRA_ARGS:remove = " --use-gl=egl"
CHROMIUM_EXTRA_ARGS:append = " --use-gl=angle"

SRC_URI:append = " \
                  file://0001-chromium-gpu-sandbox-allow-access-to-PowerVR-GPU-fro.patch \
                  file://0002-upstream-fix-incorrect-size-allocation.patch \
                  "
