do_install() {
    install -d ${D}${bindir}
    for prog in rect fb-test ; do
        install -m 0755 $prog ${D}${bindir}
    done
    #conflicts with perf
    install -m 0755 perf ${D}${bindir}/fbtest-perf
    #conflicts with mesa-demos
    install -m 0755 offset ${D}${bindir}/fbtest-offset
}

