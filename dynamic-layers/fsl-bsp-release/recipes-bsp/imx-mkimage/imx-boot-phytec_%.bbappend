DEPENDS_append_secureboot += "phytec-dev-ca-native"
do_patch_secureboot[depends] += "phytec-dev-ca-native:do_install"
