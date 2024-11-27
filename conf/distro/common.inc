DISTRO_VERSION ??= "UNASSIGNED"
DISTRO_VERSION:mx6-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6-PD22.1.1"
DISTRO_VERSION:mx6ul-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6UL-PD22.1.1"
DISTRO_VERSION:mx7-nxp-bsp = "BSP-Yocto-NXP-i.MX7-PD23.1.2"
DISTRO_VERSION:mx8mp-mainline-bsp = "BSP-Yocto-Ampliphy-i.MX8MP-kirkstone"
DISTRO_VERSION:mx8mm-nxp-bsp = "BSP-Yocto-NXP-i.MX8MM-PD23.1.0"
DISTRO_VERSION:mx8mn-nxp-bsp = "BSP-Yocto-NXP-i.MX8MM-PD23.1.0"
DISTRO_VERSION:mx8mp-nxp-bsp = "BSP-Yocto-NXP-i.MX8MP-PD23.1.0"
DISTRO_VERSION:mx8x-nxp-bsp = "BSP-Yocto-NXP-i.MX8X-kirkstone"
DISTRO_VERSION:ti33x = "BSP-Yocto-Ampliphy-AM335x-PD23.1.0"
DISTRO_VERSION:rk3288 = "BSP-Yocto-Ampliphy-RK3288-kirkstone"
DISTRO_VERSION:am57xx = "BSP-Yocto-Ampliphy-AM57x-PD24.1.0"
DISTRO_VERSION:am62xx = "BSP-Yocto-Ampliphy-AM62x-PD23.2.1"
DISTRO_VERSION:am62axx = "BSP-Yocto-Ampliphy-AM62Ax-PD23.1.1"
DISTRO_VERSION:am64xx = "BSP-Yocto-Ampliphy-AM64x-PD23.2.1"
DISTRO_VERSION:k3r5-am62xx = "${DISTRO_VERSION:am62xx}"
DISTRO_VERSION:k3r5-am62axx = "${DISTRO_VERSION:am62axx}"
DISTRO_VERSION:k3r5-am64xx = "${DISTRO_VERSION:am64xx}"
DISTRO_VERSION:j721s2 = "BSP-Yocto-Ampliphy-AM68x-PD24.1.0"
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

# Create /etc/build
INHERIT += "image-buildinfo"
IMAGE_BUILDINFO_VARS:append = " DATETIME DISTRO_NAME IMAGE_BASENAME MACHINE TUNE_PKGARCH"
IMAGE_BUILDINFO_VARS:append = " MACHINE_FEATURES DISTRO_FEATURES IMAGE_FEATURES"

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

# Define Country Code for Laird LWB WiFi chips.
# Possible Codes: US/CA/ETSI/JP/AU/CN/TW/BR/KR
# ETSI includes all member countries of the European Union.
#LWB_REGDOMAIN = "US"

PREFERRED_VERSION_mraa = "2.0.%"

# default value in bitbake.conf of poky is '/home/root'
# change to '/root' as this is preferred path
ROOT_HOME ?= "/root"
