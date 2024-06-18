RDEPENDS:${PN}:append:am57xx = " \
    ${@bb.utils.contains('MACHINE_FEATURES', 'gc320', 'ti-gc320-tests', '', d)} \
"
