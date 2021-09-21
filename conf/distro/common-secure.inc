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

DISTRO_FEATURES_append_mx6 = " trustedkey"
DISTRO_FEATURES_append_mx6ul = " trustedkey"
#trustedtpm - trustedtee - trustedcaam
TRUSTEDKEY_PREFERRED = "trustedcaam"
OVERRIDES_append_mx6 = ":trustedkey:${TRUSTEDKEY_PREFERRED}"
OVERRIDES_append_mx6ul = ":trustedkey:${TRUSTEDKEY_PREFERRED}"

# Hardening Lite for kernel config
DISTRO_FEATURES_append_mx6 = " hardening"
DISTRO_FEATURES_append_mx6ul = " hardening"
OVERRIDES_append = ":hardening"

# File system encryption
DISTRO_FEATURES += "fileencryption"
OVERRIDES_append = ":fileencryption"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"
