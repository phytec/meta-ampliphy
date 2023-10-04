FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG ??= "\
    ${@bb.utils.filter('DISTRO_FEATURES', 'efi ldconfig pam selinux usrmerge seccomp', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'rfkill', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xkbcommon', '', d)} \
    kmod \
    lz4 \
    networkd \
    resolved \
    timesyncd \
    sysusers \
    logind \
    set-time-epoch \
"

PACKAGECONFIG[acl] = "-Dacl=true,-Dacl=false,acl"
PACKAGECONFIG[kmod] = "-Dkmod=true,-Dkmod=false,kmod,libkmod"
PACKAGECONFIG[apparmor] = "-Dapparmor=true,-Dapparmor=false,"
PACKAGECONFIG[gnutls] = "-Dgnutls=true,-Dgnutls=false,gnutls"
PACKAGECONFIG[udev-hwdb] = "-Dhwdb=true,-Dhwdb=false,"

RRECOMMENDS:${PN}:remove = "systemd-compat-units"
RDEPENDS:${PN} += "systemd-conf"

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
do_install:append() {
    sed -i 's/^q \/var\/tmp.*$//g' \
        ${D}${exec_prefix}/lib/tmpfiles.d/tmp.conf
}
