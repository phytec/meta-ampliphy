PACKAGECONFIG_append = " kms"
PACKAGECONFIG_append_mx6 = " opencv zbar"
PACKAGECONFIG_append_mx6ul = " opencv zbar"
PACKAGECONFIG_append_mx8m = " opencv zbar"

PACKAGECONFIG[zbar] = "--enable-zbar,--disable-zbar,zbar"

EXTRA_OECONF_remove = "--disable-zbar"
