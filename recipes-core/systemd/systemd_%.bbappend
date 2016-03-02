FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG = "xz resolved networkd \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'pam', '', d)} \
"

RRECOMMENDS_${PN}_remove = "systemd-compat-units"
RDEPENDS_${PN} += "systemd-machine-units"

# Should be fixed in poky recipe
do_install_append () {
    if ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'false', 'true', d)}; then
        # Distro features don't contain x11. Don't install tmpfiles
        # configuration for X11.
        rm -f ${D}${exec_prefix}/lib/tmpfiles.d/x11.conf
    fi
}
