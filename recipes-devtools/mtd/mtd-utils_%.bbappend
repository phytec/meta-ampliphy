do_install_append () {
	install -d ${D}${includedir}/mtd/
	install -d ${D}${libdir}/

	install -m 0644 include/xalloc.h ${D}${includedir}/mtd/
	install -m 0644 include/version.h ${D}${includedir}/mtd/
	install -m 0644 include/common.h ${D}${includedir}/mtd/
	install -m 0644 include/libmtd.h ${D}${includedir}/mtd/

	oe_libinstall -a -C lib libmtd ${D}${libdir}/
}
