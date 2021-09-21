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

DISTRO_FEATURES:append:mx6 = " trustedkey"
DISTRO_FEATURES:append:mx6ul = " trustedkey"
#trustedtpm - trustedtee - trustedcaam
TRUSTEDKEY_PREFERRED = "trustedcaam"
OVERRIDES:append:mx6 = ":trustedkey:${TRUSTEDKEY_PREFERRED}"
OVERRIDES:append:mx6ul = ":trustedkey:${TRUSTEDKEY_PREFERRED}"

# Hardening Lite for kernel config
DISTRO_FEATURES:append:mx6 = " hardening"
DISTRO_FEATURES:append:mx6ul = " hardening"
OVERRIDES:append = ":hardening"

# File system encryption
DISTRO_FEATURES += "fileencryption"
OVERRIDES:append = ":fileencryption"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"
