DESCRIPTION = "Small and simple setup for a lighttpd server serving php over cgi"
LICENSE = "MIT"

inherit packagegroup

RDEPENDS_${PN} = " \
    lighttpd \
    lighttpd-module-cgi \
    php \
    php-cli \
"
