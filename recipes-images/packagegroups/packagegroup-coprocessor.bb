DESCRIPTION = "Demos & Examples for Co-Processors such as PRU/R5/M4 Cores."
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN}:append:k3 = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"

RDEPENDS:${PN}:remove:am62axx = "pru-icss"
RDEPENDS:${PN}:append:am62axx = " cnm-wave-fw"
RDEPENDS:${PN}:remove:j721s2 = " \
    pru-icss \
    mcu-plus-sdk-firmware \
"
RDEPENDS:${PN}:append:j721s2 = " \
    ti-rtos-firmware \
    ti-rpmsg-char \
    ti-rpmsg-char-examples \
"
