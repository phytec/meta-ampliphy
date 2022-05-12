DISTRO_VERSION ??= "UNASSIGNED"
DISTRO_VERSION:mx6-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6-kirkstone"
DISTRO_VERSION:mx6ul-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6UL-PD22.1-rc2"
DISTRO_VERSION:mx8mp-mainline-bsp = "BSP-Yocto-Ampliphy-i.MX8MP-kirkstone"
DISTRO_VERSION:ti33x = "BSP-Yocto-Ampliphy-AM335x-kirkstone"
DISTRO_VERSION:rk3288 = "BSP-Yocto-Ampliphy-RK3288-kirkstone"
VENDOR = "phytec"
TARGET_VENDOR = "-${VENDOR}"

# The bundle version interacts with the downgrade barrier.
# "r0" as version, disables the downgrade barrier. If a
# downgrade barrier is set with r1, you have to increase
# the version for every update. In that way old security
# vulnerabilities cannot be exploited.
RAUC_BUNDLE_VERSION ?= "r0"

SDK_VENDOR = "-${VENDOR}sdk"
SDK_VERSION := "${DISTRO_VERSION}"
SDK_NAME = "${VENDOR}-${DISTRO}-${TCLIBC}-${SDK_ARCH}-${IMAGE_BASENAME}-${TUNE_PKGARCH}"
SDKPATH = "/opt/${VENDOR}-${DISTRO}/${SDK_VERSION}"

#activate config checker
INHERIT += "sanity"

#we provide source mirrors for missing packages
INHERIT += "phytec-mirrors"

#run QA tests on builds and packages and log them
INHERIT += "insane"
QA_LOG = "1"

# Log information on images and packages
INHERIT += "buildhistory"
# Uncomment to disable commits
#BUILDHISTORY_COMMIT = "0"
INHERIT += "buildstats"

#run QA tests on recipes
#INHERIT += "recipe_sanity"

PACKAGE_CLASSES ?= "package_ipk"

# All images build with the distribution get the version package
IMAGE_INSTALL:append = " os-release"
PREFERRED_PROVIDER_os-release = "ampliphy-version"

# Move listet checks from ERROR_QA to WARN_QA (defined in insane.bbclass)
ERROR_TO_WARN_QA = "version-going-backwards"
ERROR_QA:remove = "${ERROR_TO_WARN_QA}"
WARN_QA:append = " ${ERROR_TO_WARN_QA}"

# suppress meta-virtualization useless warning when building
# without virtualization distro feature
SKIP_META_VIRT_SANITY_CHECK = "1"

# Suppress meta-rauc warning when building without rauc distro feature. We only
# activate this distro feature when needed in distros tailored for this
# use-case.
SKIP_META_RAUC_FEATURE_CHECK = "1"

VIRTUAL-RUNTIME_dev_manager = "udev"
VIRTUAL-RUNTIME_init_manager = "systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_login_manager = "busybox"
VIRTUAL-RUNTIME_syslog = ""
VIRTUAL-RUNTIME_initscripts = ""

# some default locales
IMAGE_LINGUAS ?= "de-de fr-fr en-us"

PREFERRED_VERSION_mraa = "2.0.%"

# default value in bitbake.conf of poky is '/home/root'
# change to '/root' as this is preferred path
ROOT_HOME ?= "/root"
