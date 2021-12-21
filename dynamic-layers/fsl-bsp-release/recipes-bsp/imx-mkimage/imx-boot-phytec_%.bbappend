DEPENDS:append:secureboot = " phytec-dev-ca-native"
do_patch:secureboot[depends] += "phytec-dev-ca-native:do_install"
