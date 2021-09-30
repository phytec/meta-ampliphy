FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

DEPENDS_append_kernelmodsign = " xz"
EXTRA_OECONF_append_kernelmodsign = " --with-xz"
