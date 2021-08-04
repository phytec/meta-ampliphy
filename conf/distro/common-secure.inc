#add secure boot to the Distro
DISTRO_FEATURES:append = " secureboot"
DISTRO_FEATURES_NATIVE:append = " secureboot"
DISTRO_FEATURES_NATIVESDK:append = " secureboot"

#kernel-modsign
DISTRO_FEATURES:append = " kernelmodsign"
DISTRO_FEATURES_NATIVE:append = " kernelmodsign"
DISTRO_FEATURES_NATIVESDK:append = " kernelmodsign"

#add protection shield level
#shieldlow - shieldmedium - shieldhigh
DISTRO_FEATURES:append = " protectionshield"
PROTECTION_SHIELD_LEVEL = "shieldlow"
#user root password for shield low and midle
#password quality decide about the protection level
PROTECTION_SHIELD_ROOT_PASSWORD ?= 'root'

DISTRO_FEATURES:append = " trustedkey"
#trustedtpm - trustedtee - trustedcaam
TRUSTEDKEY_PREFERRED = "trustedtpm"
TRUSTEDKEY_PREFERRED:mx6 = "trustedcaam"

#add class secureboot for signing Bootloader and FIT-Image
INHERIT += "secureboot"
