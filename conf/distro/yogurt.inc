#@TYPE: Distribution
#@NAME: Angstrom 
#@DESCRIPTION: Release independent distribution configuration for Angstrom

# Preserve original DISTRO value
USERDISTRO := "${DISTRO}"
DISTRO = "yogurt"
DISTRO_NAME = "Yogurt"
DISTRO_VERSION ?= "PDMaster"

BUILDNAME = "Yogurt ${DISTRO_VERSION}"

TARGET_VENDOR = "-yogurt"
SDK_VENDOR = "-yogurtsdk"

# Yocto work around for missing ONLINE_PACKAGE_MANAGEMENT support
ONLINE_PACKAGE_MANAGEMENT = "full"

# Put links to sources in deploy/sources to make it easier for people to be GPL compliant
#INHERIT += "src_distribute_local"
SRC_DIST_LOCAL ?= "symlink"

# Can be "glibc", "musl" or "uclibc"
TCLIBC ?= "glibc"

# The things *libc can provide.
PREFERRED_PROVIDER_eglibc = "glibc"

PREFERRED_PROVIDER_virtual/gettext ??= "gettext"
PREFERRED_PROVIDER_linux-libc-headers-nativesdk = "linux-libc-headers-nativesdk"

require yogurt-${TCLIBC}.inc

# Set some java bits
DEFAULTJRE ?= "openjdk-7-jre"

#Set the default maintainer to angstrom-dev
MAINTAINER = "Phytec Developers <support@phytec.de>"

#use debian style naming
INHERIT += "debian"

#activate config checker
INHERIT += "sanity" 

#activate the blacklister
INHERIT += "blacklist"

#make devshell available as task
INHERIT += "devshell" 

#use angstrom source mirrors to combat 404s
INHERIT += "phytec-mirrors" 

#run QA tests on builds and packages and log them  
INHERIT += "insane"
QA_LOG = "1"

# Log information on images and packages
INHERIT += "buildhistory"
BUILDHISTORY_COMMIT = "1"

#run QA tests on recipes
#INHERIT += "recipe_sanity"

#have a shared state a.k.a package-staging2
INHERIT += "sstate"

YOGURT_PKG_FORMAT ?= "ipk"
require yogurt-package-${YOGURT_PKG_FORMAT}.inc

# MACHINE_KERNEL_PR if not defined can cause parsing failures
# since MACHINE_KERNEL_PR is used in PR assignments in some recipes
# (meta-ti comes to mind) which means when creating FILESPATH
# it will try to evaluate it and if its undefined then python
# will except
#
# so for machines which do not define it lets define it to be empty

MACHINE_KERNEL_PR ??= "r0"

# We don't want to keep OABI compat
ARM_KEEP_OABI = "0"

#Generate locales on the buildsystem instead of on the target. Speeds up first boot, set to "1" to enable
PREFERRED_PROVIDER_qemu-native = "qemu-native"
ENABLE_BINARY_LOCALE_GENERATION ?= "1"

# We only want to build UTF8 locales
LOCALE_UTF8_ONLY = "1"

#qemu has taken a dislike to armeb as well
ENABLE_BINARY_LOCALE_GENERATION_armeb = "0"

# Prelink images
INHERIT += "image-prelink"

#Name the generated images in a sane way
IMAGE_NAME = "${DISTRO_NAME}-${IMAGE_BASENAME}-${TCLIBC}-${YOGURT_PKG_FORMAT}-${DISTRO_VERSION}-${MACHINE}"
DEPLOY_DIR_IMAGE = "${DEPLOY_DIR}/images/${MACHINE}"

# Angstrom *always* has some form of release config, so error out if someone thinks he knows better 
DISTRO_CHECK := "${@bb.data.getVar("DISTRO_VERSION",d,1) or bb.fatal('Remove this line or set a dummy DISTRO_VERSION if you really want to build an unversioned distro')}"

# We want images supporting the following features (for packagegroup(-core)-base)
DISTRO_FEATURES = "alsa argp bluetooth ext2 ipv4 ipv6 irda largefile nfs pam pci pcmcia ppp smbfs systemd usbgadget usbhost vfat wifi xattr zeroconf"

# Disable sysvinit for recipes with systemd support
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_init_manager = "systemd"
# Uncomment to completely disable support for sysv scripts:
#PACKAGECONFIG_pn-systemd = "xz"

# USE-flag like features
DISTRO_FEATURES += "tk"
DISTRO_FEATURES += "x11"
DISTRO_FEATURES += "3g"
DISTRO_FEATURES += "pulseaudio"

# OpenGL support
DISTRO_FEATURES += "opengl"
PREFERRED_PROVIDER_virtual/libgl ?= "mesa-gl"

# Inherit the default LIBC features superset from OE-core
DISTRO_FEATURES += "${DISTRO_FEATURES_LIBC}"

# Yocto tweaks
require yogurt-core-tweaks.inc
