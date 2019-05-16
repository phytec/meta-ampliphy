# Adds secure boot configuration and PKI tree creation

#default secure boot configuration
# Barebox_SIGN and FITIMAGE_SIGN is relevant by activated sign-image
#Signing Barebox
BAREBOX_SIGN ??= "true"
BAREBOX_SIGN[type] = "boolean"
BAREBOX_SIGN_IMG_PATH ??= "${CERT_SIGNINGPATH}/bootloader/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem"
BAREBOX_SIGN_CSF_PATH ??= "${CERT_SIGNINGPATH}/bootloader/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem"
BAREBOX_SIGN_SRKFUSE_PATH ??= "${CERT_SIGNINGPATH}/bootloader/crts/SRK_1_2_3_4_table.bin"

#Signing FIT image (Linux Kernel, Devicetree and optional Initramfs)
FITIMAGE_SIGN ??= "true"
FITIMAGE_SIGN[type] = "boolean"
FITIMAGE_SIGN_KEY_PATH ??= "${CERT_SIGNINGPATH}/fit/dev.key"
FITIMAGE_PUBKEY_SIGNATURE_PATH ??= "${WORKDIR}/signature_node.dtsi"
FITIMAGE_HASH ??= "sha1"
FITIMAGE_SIGNATURE_ENCRYPTION ??= "rsa2048"
FITIMAGE_SIGNER ??= "customer"
FITIMAGE_SIGNER_VERSION ??= "vPD18.1.0"
