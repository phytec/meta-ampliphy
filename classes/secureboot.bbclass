# Adds secure boot configuration and PKI tree creation

#default secure boot configuration
# Barebox_SIGN and FITIMAGE_SIGN is relevant by activated sign-image
######################################
#        Signing Bootloader          #
#####################################
BOOTLOADER_SIGN ??= "true"
BOOTLOADER_SIGN[type] = "boolean"

# for NXP i.MX6
BOOTLOADER_SIGN_IMG_PATH_mx6 ??= "${CERT_PATH}/nxp_habv4_pki/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem"
BOOTLOADER_SIGN_CSF_PATH_mx6 ??= "${CERT_PATH}/nxp_habv4_pki/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem"
BOOTLOADER_SIGN_SRKFUSE_PATH_mx6 ??= "${CERT_PATH}/nxp_habv4_pki/crts/SRK_1_2_3_4_table.bin"

##################################################
#       Signing FIT image                        #
#Linux Kernel, Devicetree and optional Initramfs)#
##################################################
FITIMAGE_SIGN ??= "true"
FITIMAGE_SIGN[type] = "boolean"

FITIMAGE_SIGNER ??= "customer"
FITIMAGE_PUBKEY_SIGNATURE_PATH ??= "${WORKDIR}/signature_node.dtsi"

# for NXP i.MX6
FITIMAGE_SIGN_KEY_PATH_mx6 ??= "${CERT_PATH}/fit/FIT-4096.key"
FITIMAGE_HASH_mx6 ??= "sha256"
FITIMAGE_SIGNATURE_ENCRYPTION_mx6 ??= "rsa4096"
FITIMAGE_SIGNER_VERSION_mx6 ??= "vPD20.0.0"
