# We don't need sensord by default. It rrecommends on lighttpd which builds php and mariadb
PACKAGECONFIG ?= ""
SYSTEMD_AUTO_ENABLE = "enable"
EXTRA_OEMAKE += 'PROG_EXTRA="sensors ${PACKAGECONFIG_CONFARGS}"'
