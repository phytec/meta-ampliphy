IMAGE_INSTALL:append += "\
    dropbear \
    linuxptp \
    iproute2 \
    tensorflow-lite \
"

IMAGE_INSTALL:append:am64xx += "\
    packagegroup-openssl-tpm2 \
    packagegroup-provision-tpm2 \
"
