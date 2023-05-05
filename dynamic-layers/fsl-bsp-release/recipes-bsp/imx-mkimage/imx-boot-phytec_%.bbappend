DEPENDS:append:secureboot = " phytec-dev-ca-native"
do_patch[depends] += "${@bb.utils.contains("DISTRO_FEATURES", "secureboot", "phytec-dev-ca-native:do_install", "", d)}"
