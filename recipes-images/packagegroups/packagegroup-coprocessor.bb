DESCRIPTION = "Demos & Examples for Co-Processors such as PRU/R5/M4 Cores."
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN}:append:k3 = " \
    mcu-plus-sdk-firmware \
"

RDEPENDS:${PN}:remove:am62axx = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"
RDEPENDS:${PN}:append:am62axx = " \
   ti-rtos-echo-test-fw \
   cnm-wave-fw \
"
RDEPENDS:${PN}:remove:j721s2 = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"
RDEPENDS:${PN}:append:j721s2 = " \
    ti-rtos-echo-test-fw \
    ti-rpmsg-char-examples \
"

RDEPENDS:${PN}:append:am57xx = " \
    ti-ipc-rtos-fw \
    ti-ipc-examples-linux \
    ti-ipc-test \
    pru-icss \
"

RDEPENDS:${PN}:remove:j722s = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"

RDEPENDS:${PN}:remove:am62pxx = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"
