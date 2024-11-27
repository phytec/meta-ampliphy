#add secure boot to the Distro
DISTRO_FEATURES:append = " secureboot"
DISTRO_FEATURES_NATIVE:append = " secureboot"
DISTRO_FEATURES_NATIVESDK:append = " secureboot"
OVERRIDES:append = ":secureboot"

#kernel-modsign
DISTRO_FEATURES:append = " kernelmodsign"
DISTRO_FEATURES_NATIVE:append = " kernelmodsign"
DISTRO_FEATURES_NATIVESDK:append = " kernelmodsign"
OVERRIDES:append = ":kernelmodsign"

#add protection shield level
#shieldlow - shieldmedium - shieldhigh
DISTRO_FEATURES:append = " protectionshield"
PROTECTION_SHIELD_LEVEL = "shieldlow"
OVERRIDES:append = ":protectionshield:${PROTECTION_SHIELD_LEVEL}"
#user root password for shield low and midle
#password quality decide about the protection level
PROTECTION_SHIELD_ROOT_PASSWORD ?= 'root'
# encrypted password for root
PROTECTION_SHIELD_ROOT_ENCRYPTED_PASSWORD ?= 'PI9ZxRHV.sgB6'

# Hardening Lite for kernel config
DISTRO_FEATURES:append:mx6-generic-bsp = " hardening"
DISTRO_FEATURES:append:mx6ul-generic-bsp = " hardening"
DISTRO_FEATURES:append:mx8m-nxp-bsp = " hardening"
OVERRIDES:append = ":hardening"
# Deselect some kernel features that aren't always needed in ampliphy- secure
KERNEL_FEATURES_DESELECT ?= "debug kvm media xen"

# File system encryption
DISTRO_FEATURES += "securestorage"
# possible values: fileauthorenc , fileauthandenc
SECURE_STORAGE_TYPE ??= "fileauthandenc"
OVERRIDES:append = ":securestorage:${SECURE_STORAGE_TYPE}"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"

# Sign kernel fitImage
UBOOT_SIGN_ENABLE:mx8m-nxp-bsp = "1"
UBOOT_SIGN_KEYDIR:mx8m-nxp-bsp = "${CERT_PATH}/fit"
UBOOT_SIGN_KEYNAME:mx8m-nxp-bsp = "FIT-4096"
FIT_SIGN_ALG:mx8m-nxp-bsp = "rsa4096"