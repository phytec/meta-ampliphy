RDEPENDS:${PN}-install:append = " \
    ${@bb.utils.contains("MACHINE_FEATURES", "caam", "keyctl-caam", "", d)} \
"
