FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGES =+ "\
    ${PN}-extra-utils \
"

# remove has higher priority as packageconfig and depends so those
# lines need to be maintained and kept sync for the append
PACKAGECONFIG_append = " lz4 kmod networkd resolved"
PACKAGECONFIG_remove = " xz ldconfig"
DEPENDS_remove = ""
RDEPENDS_${PN}_remove = ""

PACKAGECONFIG[nls] = "--enable-nls,--disable-nls,intltool-native"
PACKAGECONFIG[acl] = "--enable-acl,--disable-acl,acl"
PACKAGECONFIG[lz4] = "--enable-lz4,--disable-lz4,lz4"
PACKAGECONFIG[zlib] = "--enable-zlib,--disable-zlib,zlib"
PACKAGECONFIG[bzip2] = "--enable-bzip2,--disable-bzip2,bzip2"
PACKAGECONFIG[dbus] = "--enable-dbus,--disable-dbus,dbus,dbus"
PACKAGECONFIG[utmp] = "--enable-utmp,--disable-utmp,"
PACKAGECONFIG[kmod] = "--enable-kmod,--disable-kmod,kmod,libkmod"
PACKAGECONFIG[apparmor] = "--enable-apparmor,--disable-apparmor,"
PACKAGECONFIG[smack] = "--enable-smack,--disable-smack,"
PACKAGECONFIG[ima] = "--enable-ima,--disable-ima,"
PACKAGECONFIG[polkit] = "--enable-polkit,--disable-polkit,"
PACKAGECONFIG[gnutls] = "--enable-gnutls,--disable-gnutls,gnutls"
PACKAGECONFIG[efi] = "--enable-efi,--disable-efi,"
PACKAGECONFIG[gnuefi] = "--enable-gnuefi,--disable-gnuefi,"
PACKAGECONFIG[kdbus] = "--enable-kdbus,--disable-kdbus"
PACKAGECONFIG[myhostname] = "--enable-myhostname,--disable-myhostname"
PACKAGECONFIG[udev-hwdb] = "--enable-hwdb,--disable-hwdb,"
PACKAGECONFIG[hibernate] = "--enable-hibernate,--disable-hibernate"
PACKAGECONFIG[timesyncd] = "--enable-timesyncd,--disable-timesyncd,"
PACKAGECONFIG[machined] = "--enable-machined,--disable-machined"

# additions from upstream master
PACKAGECONFIG[backlight] = "--enable-backlight,--disable-backlight"
PACKAGECONFIG[quotacheck] = "--enable-quotacheck,--disable-quotacheck"
PACKAGECONFIG[bootchart] = "--enable-bootchart,--disable-bootchart"
PACKAGECONFIG[hostnamed] = "--enable-hostnamed,--disable-hostnamed"
PACKAGECONFIG[rfkill] = "--enable-rfkill,--disable-rfkill"
PACKAGECONFIG[timedated] = "--enable-timedated,--disable-timedated"
PACKAGECONFIG[localed] = "--enable-localed,--disable-localed"
# libseccomp is found in meta-security
PACKAGECONFIG[seccomp] = "--enable-seccomp,--disable-seccomp,libseccomp"
PACKAGECONFIG[logind] = "--enable-logind,--disable-logind"
# disabling this breaks some other systemd tools
#PACKAGECONFIG[sysusers] = "--enable-sysusers,--disable-sysusers"
PACKAGECONFIG[firstboot] = "--enable-firstboot,--disable-firstboot"
PACKAGECONFIG[randomseed] = "--enable-randomseed,--disable-randomseed"
# needs upstream recipe fix
#PACKAGECONFIG[binfmt] = "--enable-binfmt,--disable-binfmt"

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
    sed -i 's/^v \/var\/tmp.*$//g' \
        ${D}${exec_prefix}/lib/tmpfiles.d/tmp.conf
}

FILES_${PN}-extra-utils = "\
                        ${base_bindir}/systemd-escape \
                        ${base_bindir}/systemd-inhibit \
                        ${bindir}/systemd-detect-virt \
                        ${bindir}/systemd-path \
                        ${bindir}/systemd-run \
                        ${bindir}/systemd-cat \
                        ${bindir}/systemd-delta \
                        ${bindir}/systemd-cgls \
                        ${bindir}/systemd-cgtop \
                        ${bindir}/systemd-stdio-bridge \
                        ${base_bindir}/systemd-ask-password \
                        ${base_bindir}/systemd-tty-ask-password-agent \
                        ${systemd_unitdir}/system/systemd-ask-password-console.path \
                        ${systemd_unitdir}/system/systemd-ask-password-console.service \
                        ${systemd_unitdir}/system/systemd-ask-password-wall.path \
                        ${systemd_unitdir}/system/systemd-ask-password-wall.service \
                        ${systemd_unitdir}/system/sysinit.target.wants/systemd-ask-password-console.path \
                        ${systemd_unitdir}/system/sysinit.target.wants/systemd-ask-password-wall.path \
                        ${systemd_unitdir}/system/multi-user.target.wants/systemd-ask-password-wall.path \
                        ${rootlibexecdir}/systemd/systemd-resolve-host \
                        ${rootlibexecdir}/systemd/systemd-ac-power \
                        ${rootlibexecdir}/systemd/systemd-activate \
                        ${bindir}/systemd-nspawn \
                        ${exec_prefix}/lib/tmpfiles.d/systemd-nspawn.conf \
                        ${systemd_unitdir}/system/systemd-nspawn@.service \
                        ${rootlibexecdir}/systemd/systemd-bus-proxyd \
                        ${systemd_unitdir}/system/systemd-bus-proxyd.service \
                        ${systemd_unitdir}/system/systemd-bus-proxyd.socket \
                        ${rootlibexecdir}/systemd/systemd-socket-proxyd \
                        ${rootlibexecdir}/systemd/systemd-reply-password \
                        ${rootlibexecdir}/systemd/systemd-sleep \
                        ${rootlibexecdir}/systemd/system-sleep \
                        ${systemd_unitdir}/system/systemd-hibernate.service \
                        ${systemd_unitdir}/system/systemd-hybrid-sleep.service \
                        ${systemd_unitdir}/system/systemd-suspend.service \
                        ${systemd_unitdir}/system/sleep.target \
                        ${rootlibexecdir}/systemd/systemd-initctl \
                        ${systemd_unitdir}/system/systemd-initctl.service \
                        ${systemd_unitdir}/system/systemd-initctl.socket \
                        ${systemd_unitdir}/system/sockets.target.wants/systemd-initctl.socket \
                        ${rootlibexecdir}/systemd/system-generators/systemd-gpt-auto-generator \
                        ${rootlibexecdir}/systemd/systemd-cgroups-agent \
"
# upstream sets this as default, we want the small image version to be
# the default
#RRECOMMENDS_${PN} += "systemd-extra-utils"
