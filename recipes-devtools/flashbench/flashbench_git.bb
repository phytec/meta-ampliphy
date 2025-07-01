DESCRIPTION = "Tool for benchmarking and classifying flash memory drives"
HOMEPAGE = "https://git.linaro.org/people/arnd.bergmann/flashbench.git"
SECTION = "misc"
DEPENDS = ""

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=b234ee4d69f5fce4486a80fdaf4a4263"


SRC_URI = "git://git.linaro.org/people/arnd.bergmann/flashbench.git;protocol=https;branch=master"
SRC_URI += "\
    file://0001-flashbench-fix-Makefile.patch \
"

# There are no upstream tags/releases.
SRCREV = "2e30b1968a66147412f21002ea844122a0d5e2f0"
PR = "r0"
PV = "0.1+${SRCPV}"

# No configure/autotools. Only a simple Makefile.
do_configure[noexec] = "1"

do_install () {
    install -Dm 755 ${B}/flashbench ${D}${bindir}/flashbench
    install -Dm 755 ${B}/erase ${D}${bindir}/erase
}
