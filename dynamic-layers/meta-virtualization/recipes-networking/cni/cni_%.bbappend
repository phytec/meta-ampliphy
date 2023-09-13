SRCREV_dnsname_plugin = "6685f68dbc13a95b73b9394b304927c6f518021c"

SRC_URI:append = " \
	git://github.com/containers/dnsname;branch=main;name=dnsname_plugin;protocol=https;destsuffix=${S}/src/github.com/containers/dnsname \
"

do_compile:prepend() {
	ln -sfr ${S}/src/github.com/containers/dnsname/plugins/meta/dnsname ${S}/src/github.com/containernetworking/plugins/plugins/meta/dnsname
}

RDEPENDS:${PN} += "dnsmasq"
