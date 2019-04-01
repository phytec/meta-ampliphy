FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

#This setup adds about 1.3MB to the 4.4MB of the all disabled configuration
PACKAGECONFIG ??= "\
    ${@bb.utils.filter('DISTRO_FEATURES', 'efi ldconfig pam selinux usrmerge', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'rfkill', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xkbcommon', '', d)} \
    kmod \
    lz4 \
    networkd \
    resolved \
    sysusers \
"

PACKAGECONFIG[acl] = "-Dacl=true,-Dacl=false,acl"
PACKAGECONFIG[kmod] = "-Dkmod=true,-Dkmod=false,kmod,libkmod"
PACKAGECONFIG[apparmor] = "-Dapparmor=true,-Dapparmor=false,"
PACKAGECONFIG[gnutls] = "-Dgnutls=true,-Dgnutls=false,gnutls"
PACKAGECONFIG[gnuefi] = "-Dgnu-efi=true,-Dgnu-efi=false,"
PACKAGECONFIG[udev-hwdb] = "-Dhwdb=true,-Dhwdb=false,"

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

# Should be fixed in poky recipe
#
# Fix runtime error of systemd-tmpfiles service:
#    Failed to open directory /var/tmp: Too many levels of symbolic links
# The error happens beceause poky adds a symbolic link from /var/tmp to tmpfs
# /var/volatile/tmp and systemd-tmpfiles open the directory with O_NOFOLLOW.
#
# Since poky/oe-core installs alredy an extra cleanup configuration for
# /var/volatile/tmp  in
#    meta/recipes-core/systemd/systemd/00-create-volatile.conf
# the line must be removed completely in tmp.conf.
do_install_append() {
    sed -i 's/^q \/var\/tmp.*$//g' \
        ${D}${exec_prefix}/lib/tmpfiles.d/tmp.conf
}
