SUMMARY = "System initialization program"
HOMEPAGE = "https://github.com/phytec/partup"

LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5b4473596678d62d9d83096273422c8c"

inherit meson pkgconfig

DEPENDS = "glib-2.0 libyaml parted"

do_install:append() {
    install -d ${D}${datadir}/partup
    install -m 644 ${S}/dist/config/*.yaml ${D}${datadir}/partup/
}
