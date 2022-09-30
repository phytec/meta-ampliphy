IMAGE_INSTALL:append += "\
    dropbear \
    linuxptp \
    iproute2 \
    tensorflow-lite \
    memtester \
    stressapptest \
    v4l-utils \
    media-ctl \
    yavta \
"

IMAGE_INSTALL:append:am64xx += "\
    packagegroup-openssl-tpm2 \
    packagegroup-provision-tpm2 \
"
