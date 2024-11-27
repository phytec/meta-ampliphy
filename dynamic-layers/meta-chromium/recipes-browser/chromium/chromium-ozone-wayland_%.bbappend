DEPENDS += "\
    icu-native \
"

GN_ARGS += " \
    use_system_icu=true \
    icu_use_data_file=true \
"
