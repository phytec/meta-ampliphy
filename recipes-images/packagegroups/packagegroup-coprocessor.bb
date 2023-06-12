DESCRIPTION = "Demos & Examples for Co-Processors such as PRU/R5/M4 Cores."
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

# Include AM62/AM64 examples from meta-ti
RDEPENDS:${PN}:append:k3 = " \
    ti-rtos-firmware \
    pru-icss \
    ti-rpmsg-char \
    ti-rpmsg-char-examples \
"

RDEPENDS:${PN}:remove:am62axx = "pru-icss"
RDEPENDS:${PN}:append:am62axx = " cnm-wave-fw"
