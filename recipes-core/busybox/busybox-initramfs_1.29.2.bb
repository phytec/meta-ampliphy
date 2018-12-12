FILESEXTRAPATHS_prepend := "\
${COREBASE}/meta/recipes-core/busybox/files:\
${COREBASE}/meta/recipes-core/busybox/busybox:\
${COREBASE}/meta/recipes-core/busybox/busybox-${PV}:\
${THISDIR}/${PN}:"

require recipes-core/busybox/busybox_${PV}.bb

# include init.cfg independently from VIRTUAL-RUNTIME_init_manager
SRC_URI_append = " file://init.cfg"

S = "${WORKDIR}/busybox-${PV}"

# redepens independently from VIRTUAL-RUNTIME_init_manager
RDEPENDS_${PN} = "busybox-inittab"
