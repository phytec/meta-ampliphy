#add secure boot to the Distro
DISTRO_FEATURES_append = " secureboot"
DISTRO_FEATURES_NATIVE_append = " secureboot"
DISTRO_FEATURES_NATIVESDK_append = " secureboot"
OVERRIDES_append = ":secureboot"

#kernel-modsign
DISTRO_FEATURES_append = " kernelmodsign"
DISTRO_FEATURES_NATIVE_append = " kernelmodsign"
DISTRO_FEATURES_NATIVESDK_append = " kernelmodsign"
OVERRIDES_append = ":kernelmodsign"

#add protection shield level
#shieldlow - shieldmedium - shieldhigh
DISTRO_FEATURES_append = " protectionshield"
PROTECTION_SHIELD_LEVEL = "shieldlow"
OVERRIDES_append = ":protectionshield:${PROTECTION_SHIELD_LEVEL}"
#user root password for shield low and midle
#password quality decide about the protection level
PROTECTION_SHIELD_ROOT_PASSWORD ?= 'root'

# Hardening Lite for kernel config
DISTRO_FEATURES_append_mx6 = " hardening"
DISTRO_FEATURES_append_mx6ul = " hardening"
OVERRIDES_append = ":hardening"

# File system encryption
DISTRO_FEATURES += "securestorage"
# possible values: fileauthorenc , fileauthandenc
SECURE_STORAGE_TYPE ??= "fileauthandenc"
OVERRIDES_append = ":securestorage:${SECURE_STORAGE_TYPE}"

# Enable experimental OP-TEE support
MACHINE_FEATURES_append_mx8mm = " optee"
MACHINE_FEATURES_append_mx8mn = " optee"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"
