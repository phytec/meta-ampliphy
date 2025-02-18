FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

PACKAGECONFIG ??= "\
    ${@bb.utils.filter('DISTRO_FEATURES', 'acl efi ldconfig pam selinux usrmerge seccomp', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wifi', 'rfkill', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11', 'xkbcommon', '', d)} \
    cgroupv2 \
    kmod \
    lz4 \
    networkd \
    resolved \
    timedated \
    timesyncd \
    sysusers \
    logind \
    set-time-epoch \
"

PACKAGECONFIG[apparmor] = "-Dapparmor=true,-Dapparmor=false,"
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
#
# Fix runtime error of systemd-tmpfiles service:
#    "/var/log" already exists and is not a directory.
# This error triggers because poky adds a symbolic link from /var/log to
# tmpfs /var/volatile/log and systemd-tmpfiles try to open it as a
# directory. Cleanup configuration for /var/volatile/log already exists
# in 00-create-volatile.conf.
do_install:append() {
    sed -i 's/^q \/var\/tmp.*$//g' \
        ${D}${exec_prefix}/lib/tmpfiles.d/tmp.conf
    sed -i 's/^d \/var\/log.*$/L \/var\/log - - - - \/var\/volatile\/log/' \
        ${D}${exec_prefix}/lib/tmpfiles.d/var.conf
}
