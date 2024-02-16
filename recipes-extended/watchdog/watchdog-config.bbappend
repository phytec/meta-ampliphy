do_install:append:am62xx() {
    echo "interval = 40" >> ${D}/etc/watchdog.conf
}
