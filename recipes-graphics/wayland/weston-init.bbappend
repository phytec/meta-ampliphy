FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI += "file://weston.ini"

do_install:append() {
    mkdir -p ${D}/home/weston/
    touch ${D}/home/weston/.profile
    touch ${D}/home/weston/.bashrc
}
