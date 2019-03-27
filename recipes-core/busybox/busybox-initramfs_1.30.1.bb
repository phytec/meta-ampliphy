FILESEXTRAPATHS_prepend := "\
${COREBASE}/meta/recipes-core/busybox/files:\
${COREBASE}/meta/recipes-core/busybox/busybox:\
${COREBASE}/meta/recipes-core/busybox/busybox-${PV}:\
${THISDIR}/${PN}:"

require recipes-core/busybox/busybox_${PV}.bb

# fixup security flags. This usually gets maintained at the distro level
# in poky in the file security_flags.inc
# for us it is easier to maintain it per recipe. So whenever you update the
# busybox version, have a look at the poky file to see if busybox can now
# be build with security flags enabled and remove this line
SECURITY_STRINGFORMAT= ""

# include init.cfg independently from VIRTUAL-RUNTIME_init_manager
SRC_URI_append = " file://init.cfg"

S = "${WORKDIR}/busybox-${PV}"

# redepens independently from VIRTUAL-RUNTIME_init_manager
RDEPENDS_${PN} = "busybox-inittab"
