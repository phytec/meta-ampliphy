FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

DEPENDS:append_kernelmodsign = " xz"
EXTRA_OECONF:append_kernelmodsign = " --with-xz"
