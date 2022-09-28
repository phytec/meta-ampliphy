IMAGE_INSTALL_append += "\
    dropbear \
    linuxptp \
    iproute2 \
    tensorflow-lite \
"

IMAGE_INSTALL_append_am64xx += "\
    packagegroup-openssl-tpm2 \
    packagegroup-provision-tpm2 \
"
