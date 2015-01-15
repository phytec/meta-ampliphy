DESCRIPTION = "Task to install graphics binaries"
LICENSE = "MIT"
PR = "r6"

PACKAGE_ARCH = "${MACHINE_ARCH}"
inherit packagegroup

GRAPHICS_WESTON = "\
    weston \
    weston-init \
    weston-examples \
"

GRAPHICS_SDK = "\
    libgles-omap3 \
    libgles-omap3-blitwsegl \
    libgles-omap3-flipwsegl \
    libgles-omap3-frontwsegl \
    libgles-omap3-linuxfbwsegl \
    libgles-omap3-rawdemos \
    omap3-sgx-modules \
"

GRAPHICS_RDEPENDS = ""
GRAPHICS_RDEPENDS_ti33x = "\
    ${GRAPHICS_SDK} \
"

GRAPHICS_RDEPENDS_ti43x = "\
    ${GRAPHICS_SDK} \
"

GRAPHICS_RDEPENDS_omap3 = "\
    ${GRAPHICS_SDK} \
"

GRAPHICS_RDEPENDS_omap-a15 = "\
    libgbm \
    omap5-sgx-ddk-um-linux \
    "
# Put this back when compile issues are fixed against 3.14
#    omapdrm-pvr

GRAPHICS_BLTSVILLE = ""
GRAPHICS_BLTSVILLE_omap-a15 = " \
    bltsville   \
    "

RDEPENDS_${PN} = "\
    ${GRAPHICS_WESTON} \
    ${GRAPHICS_RDEPENDS} \
    ${GRAPHICS_BLTSVILLE} \
"
