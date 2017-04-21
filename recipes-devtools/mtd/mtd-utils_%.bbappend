do_install_append () {
	install -d ${D}${includedir}/mtd/
	install -d ${D}${libdir}/

	install -m 0644 ${S}include/xalloc.h ${D}${includedir}/mtd/
	install -m 0644 ${S}include/common.h ${D}${includedir}/mtd/
	install -m 0644 ${S}include/libmtd.h ${D}${includedir}/mtd/
	install -m 0644 ${B}/include/config.h ${D}${includedir}/mtd/

	oe_libinstall -a -C ${B} libmtd ${D}${libdir}/
}
