#add secure boot to the Distro
DISTRO_FEATURES_append = " secureboot"
DISTRO_FEATURES_NATIVE_append = " secureboot"
DISTRO_FEATURES_NATIVESDK_append = " secureboot"

#kernel-modsign
DISTRO_FEATURES_append = " kernelmodsign"
DISTRO_FEATURES_NATIVE_append = " kernelmodsign"
DISTRO_FEATURES_NATIVESDK_append = " kernelmodsign"

#add protection shield level
#shieldlow - shieldmedium - shieldhigh
DISTRO_FEATURES_append = " protectionshield"
PROTECTION_SHIELD_LEVEL = "shieldlow"
#user root password for shield low and midle
#password quality decide about the protection level
PROTECTION_SHIELD_ROOT_PASSWORD ?= 'root'

# File system encryption
DISTRO_FEATURES += "fileencryption"
OVERRIDES_append = ":fileencryption"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"
