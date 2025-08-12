DISTRO_VERSION ??= "UNASSIGNED"
DISTRO_VERSION:mx6-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6-walnascar"
DISTRO_VERSION:mx6ul-generic-bsp = "BSP-Yocto-Ampliphy-i.MX6UL-walnascar"
DISTRO_VERSION:mx7-nxp-bsp = "BSP-Yocto-NXP-i.MX7-walnascar"
DISTRO_VERSION:mx8mm-mainline-bsp = "BSP-Yocto-Ampliphy-i.MX8MM-walnascar"
DISTRO_VERSION:mx8mn-mainline-bsp = "${DISTRO_VERSION:mx8mm-mainline-bsp}"
DISTRO_VERSION:mx8mp-mainline-bsp = "BSP-Yocto-Ampliphy-i.MX8MP-walnascar"
DISTRO_VERSION:mx8mm-nxp-bsp = "BSP-Yocto-NXP-i.MX8MM-walnascar"
DISTRO_VERSION:mx8mn-nxp-bsp = "${DISTRO_VERSION:mx8mm-nxp-bsp}"
DISTRO_VERSION:mx8mp-nxp-bsp = "BSP-Yocto-NXP-i.MX8MP-walnascar"
DISTRO_VERSION:mx93-generic-bsp = "BSP-Yocto-NXP-i.MX93-walnascar"
DISTRO_VERSION:ti33x = "BSP-Yocto-Ampliphy-AM335x-walnascar"
DISTRO_VERSION:am57xx = "BSP-Yocto-Ampliphy-AM57x-walnascar"
DISTRO_VERSION:am62xx = "BSP-Yocto-Ampliphy-AM62x-walnascar"
DISTRO_VERSION:k3r5-am62xx = "${DISTRO_VERSION:am62xx}"
DISTRO_VERSION:am62axx = "BSP-Yocto-Ampliphy-AM62Ax-walnascar"
DISTRO_VERSION:k3r5-am62axx = "${DISTRO_VERSION:am62axx}"
DISTRO_VERSION:am62pxx = "BSP-Yocto-Ampliphy-AM62Px-walnascar"
DISTRO_VERSION:k3r5-am62pxx = "${DISTRO_VERSION:am62pxx}"
DISTRO_VERSION:am64xx = "BSP-Yocto-Ampliphy-AM64x-walnascar"
DISTRO_VERSION:k3r5-am64xx = "${DISTRO_VERSION:am64xx}"
DISTRO_VERSION:am67xx = "BSP-Yocto-Ampliphy-AM67x-walnascar"
DISTRO_VERSION:k3r5-am67xx = "${DISTRO_VERSION:am67xx}"
DISTRO_VERSION:j721s2 = "BSP-Yocto-Ampliphy-AM68x-walnascar"
DISTRO_VERSION:rk3288 = "BSP-Yocto-Ampliphy-RK3288-walnascar"

# DISTRO_VERSION's development-build marker '-devel'
DISTRO_VERSION:append = "${@ '' if d.getVar('BB_PHY_BUILDTYPE') == "RELEASE" else '-devel' }"

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

# Create /etc/build
INHERIT += "image-buildinfo"
IMAGE_BUILDINFO_VARS:append = " DATETIME DISTRO_NAME IMAGE_BASENAME MACHINE TUNE_PKGARCH"
IMAGE_BUILDINFO_VARS:append = " MACHINE_FEATURES DISTRO_FEATURES IMAGE_FEATURES"

# All images build with the distribution get the version package
IMAGE_INSTALL:append = " os-release"
PREFERRED_PROVIDER_os-release = "ampliphy-version"

# Move listet checks from ERROR_QA to WARN_QA (defined in insane.bbclass)
ERROR_TO_WARN_QA = "version-going-backwards"
ERROR_QA:remove = "${ERROR_TO_WARN_QA}"
WARN_QA:append = " ${ERROR_TO_WARN_QA}"

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
IMAGE_LINGUAS ?= "de-de fr-fr en-us zh-cn"

# Define Country Code for Laird LWB WiFi chips.
# Possible Codes: US/CA/ETSI/JP/AU/CN/TW/BR/KR
# ETSI includes all member countries of the European Union.
#LWB_REGDOMAIN = "US"

PREFERRED_VERSION_mraa = "2.0.%"
PREFERRED_RPROVIDER_util-linux-sfdisk-native = "util-linux-native"

# default value in bitbake.conf of poky is '/home/root'
# change to '/root' as this is preferred path
ROOT_HOME ?= "/root"

DISTRO_FEATURES_DEFAULT:remove = "pcmcia zeroconf"
DISTRO_FEATURES = "${DISTRO_FEATURES_DEFAULT} \
    opengl \
    systemd \
    usrmerge \
    wayland \
    pam \
    virtualization \
    security \
    ${@bb.utils.filter('MACHINE_FEATURES', 'tpm tpm2', d)}"
DISTRO_FEATURES:append:mx95-generic-bsp = " vulkan"
VIRTUAL-RUNTIME_container_runtime ?= "crun"
DISTRO_FEATURES:remove:mx6ul-generic-bsp = "opengl wayland"
DISTRO_FEATURES:remove:am57x6 = "opengl"
DISTRO_FEATURES:remove:ti33x = "virtualization"

IMAGE_BOOT_FILES:append:k3 = " boot.scr.uimg"
WKS_FILE_DEPENDS:append:k3 = " ampliphy-boot"
WKS_FILE_DEPENDS:append:mx8-generic-bsp = " ampliphy-boot"
WKS_FILE_DEPENDS:append:mx95-generic-bsp = " ampliphy-boot"
PARTUP_PACKAGE_DEPENDS:append:k3 = " ampliphy-boot"
PARTUP_PACKAGE_DEPENDS:append:mx8-generic-bsp = " ampliphy-boot"
PARTUP_PACKAGE_DEPENDS:append:mx95-generic-bsp = " ampliphy-boot"

# Dependency used by RAUC bundles and sbom-cyclonedx class
DEP_BOOTLOADER ?= "${PREFERRED_PROVIDER_virtual/bootloader}"
DEP_BOOTLOADER:mx8-nxp-bsp = "${IMAGE_BOOTLOADER}"
DEP_BOOTLOADER:mx91-nxp-bsp = "${IMAGE_BOOTLOADER}"
DEP_BOOTLOADER:mx93-nxp-bsp = "${IMAGE_BOOTLOADER}"
DEP_BOOTLOADER:k3 = "${IMAGE_BOOTLOADER}"

# Set a more generic tune for better package reuse across different machines
DEFAULTTUNE:mx8-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx8m-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx8mm-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx8mn-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx8mp-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx8x-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx91-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx93-generic-bsp ?= "aarch64"
DEFAULTTUNE:mx95-generic-bsp ?= "aarch64"
