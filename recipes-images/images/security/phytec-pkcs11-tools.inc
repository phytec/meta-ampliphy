
IMAGE_INSTALL:append = " \
    opensc \
    libp11 \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "tpm2-pkcs11", "",  d)} \
"
