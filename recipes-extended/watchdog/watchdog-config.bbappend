do_install:append:am62xx() {
    echo "interval = 40" >> ${D}/etc/watchdog.conf
}

do_install:append:am62axx() {
    echo "interval = 40" >> ${D}/etc/watchdog.conf
}
