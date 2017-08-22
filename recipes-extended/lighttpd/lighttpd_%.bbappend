FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"
RDEPENDS_${PN} += " \
    lighttpd-module-cgi \
"
RRECOMMENDS_${PN} += " \
    php-cli \
"
