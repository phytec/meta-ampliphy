do_compile_append () {
    oe_runmake sub-examples
}
do_install_append () {
    oe_runmake sub-examples-install_subtargets INSTALL_ROOT=${D}
}
