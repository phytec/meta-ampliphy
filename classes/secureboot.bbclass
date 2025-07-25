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

# AHAB
AHAB_SRK_TABLE_BIN ?= "${CERT_PATH}/nxp_ahab_pki/crts/SRK_1_2_3_4_table.bin"
AHAB_SRK_PUB_CERT ?= "${CERT_PATH}/nxp_ahab_pki/crts/SRK1_sha512_secp521r1_v3_usr_crt.pem"
AHAB_SRK_INDEX ?= "0"

# for TI K3
BOOTLOADER_TI_K3_MPK_KEY ??= "${CERT_PATH}/ti_k3/keys/phytecSMPK.pem"
BOOTLOADER_TI_K3_DEGENERATE_KEY ??= "${CERT_PATH}/ti_k3/keys/ti-degenerate-key.pem"

##################################################
#       Signing FIT image                        #
#Linux Kernel, Devicetree and optional Initramfs)#
##################################################

FITIMAGE_NO_DTB_OVERLAYS ?= "false"
FITIMAGE_NO_DTB_OVERLAYS[type] = "boolean"

FITIMAGE_SIGN_ENGINE ?= "software"

UBOOT_SIGN_KEYDIR = "${CERT_PATH}/fit"
UBOOT_SIGN_KEYNAME = "FIT-4096"
FIT_SIGN_ALG = "rsa4096"
FIT_HASH_ALG = "sha256"

# Set set the following variables for pkcs11 signing
# PKCS11_MODULE_PATH = ""
# UBOOT_SIGN_KEYDIR = "pkcs11:"
# UBOOT_SIGN_KEYNAME = ""
# Set pkcs11 as signing engine
# UBOOT_MKIMAGE_SIGN_ARGS = "-N pkcs11"
UBOOT_MKIMAGE_SIGN_ARGS ?= ""
