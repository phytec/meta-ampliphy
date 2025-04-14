# Adds secure boot configuration and PKI tree creation

#default secure boot configuration
# Barebox_SIGN and FITIMAGE_SIGN is relevant by activated sign-image
######################################
#        Signing Bootloader          #
#####################################
CERT_PATH ??= "${OEROOT}/../../phytec-dev-ca"
# for NXP HABv4 based systems
BOOTLOADER_SIGN_IMG_PATH ??= "${CERT_PATH}/nxp_habv4_pki/crts/IMG1_1_sha256_4096_65537_v3_usr_crt.pem"
BOOTLOADER_SIGN_CSF_PATH ??= "${CERT_PATH}/nxp_habv4_pki/crts/CSF1_1_sha256_4096_65537_v3_usr_crt.pem"
BOOTLOADER_SIGN_SRKFUSE_PATH ??= "${CERT_PATH}/nxp_habv4_pki/crts/SRK_1_2_3_4_table.bin"
BOOTLOADER_HABV4_SRK_INDEX ??= "0"

# for TI K3
BOOTLOADER_TI_K3_MPK_KEY ??= "${CERT_PATH}/ti_k3/keys/phytecSMPK.pem"
BOOTLOADER_TI_K3_DEGENERATE_KEY ??= "${CERT_PATH}/ti_k3/keys/ti-degenerate-key.pem"

##################################################
#       Signing FIT image                        #
#Linux Kernel, Devicetree and optional Initramfs)#
##################################################
FITIMAGE_SIGN ??= "false"
FITIMAGE_SIGN[type] = "boolean"

FITIMAGE_NO_DTB_OVERLAYS ?= "false"
FITIMAGE_NO_DTB_OVERLAYS[type] = "boolean"

FITIMAGE_SIGNER ?= "customer"
FITIMAGE_PUBKEY_SIGNATURE_PATH ?= "${WORKDIR}/signature_node.dtsi"

FITIMAGE_SIGN_ENGINE ?= "software"

FITIMAGE_SIGN_KEY_PATH ?= "${CERT_PATH}/fit/FIT-4096.key"
FITIMAGE_HASH ?= "sha256"
FITIMAGE_SIGNATURE_ENCRYPTION ?= "rsa4096"
FITIMAGE_SIGNER_VERSION ?= "vPD20.0.0"
