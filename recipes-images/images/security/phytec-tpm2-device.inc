IMAGE_INSTALL:append = " \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "libtss2-tcti-device", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "libtss2-tcti-mssim", "", d)} \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "libtss2-mu", "", d)} \
"
