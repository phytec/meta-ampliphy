INHERIT += "package_ipk"

EXTRAOPKGCONFIG = "opkg-config-base"

YOGURT_IPK_UPDATE_ALTERNATIVES ?= "update-alternatives-opkg"

DISTRO_UPDATE_ALTERNATIVES = "${YOGURT_IPK_UPDATE_ALTERNATIVES}"

# we need the same provider for opkg and u-a
PREFERRED_PROVIDER_virtual/update-alternatives-native ?= "opkg-utils-native"
PREFERRED_PROVIDER_virtual/update-alternatives = "opkg-utils"
VIRTUAL-RUNTIME_update-alternatives = "${YOGURT_IPK_UPDATE_ALTERNATIVES}"

