do_install_append() {
    if ${@bb.utils.contains("PACKAGECONFIG", "samples", "true", "false", d)}; then
        install -d ${D}${datadir}/OpenCV/samples/bin/
        cp -f ${B}/bin/example_* ${D}${datadir}/OpenCV/samples/bin/
    fi
}
