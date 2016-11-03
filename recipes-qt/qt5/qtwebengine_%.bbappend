do_compile_append () {
    oe_runmake sub-examples
}
do_install_append () {
    oe_runmake sub-examples-install_subtargets INSTALL_ROOT=${D}
    sed -i 's@ -Wl,--start-group.*-Wl,--end-group@@g; s@-L${B}[^ ]* @ @g' ${D}${libdir}/pkgconfig/Qt5WebEngineCore.pc
}
