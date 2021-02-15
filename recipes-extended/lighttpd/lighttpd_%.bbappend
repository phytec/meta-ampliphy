FILESEXTRAPATHS_prepend := "${THISDIR}/${BPN}:"
RDEPENDS_${PN} += " \
    lighttpd-module-cgi \
"
RRECOMMENDS_${PN} += " \
    php-cli \
"
