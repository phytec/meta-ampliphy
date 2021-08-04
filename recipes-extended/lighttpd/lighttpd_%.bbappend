FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"
RDEPENDS:${PN} += " \
    lighttpd-module-cgi \
"
RRECOMMENDS:${PN} += " \
    php-cli \
"
