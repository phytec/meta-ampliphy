DISTRO_VERSION ??= "UNASSIGNED"
DISTRO_VERSION_mx6 = "i.MX6-PD-master"
DISTRO_VERSION_mx6ul = "i.MX6UL-PD-master"
DISTRO_VERSION_ti33x = "AM335x-PD-master"
DISTRO_VERSION_rk3288 = "RK3288-PD-master"
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
BUILDHISTORY_COMMIT = "1"
INHERIT += "buildstats"

# Prelink images
INHERIT += "image-prelink"

# optimize lib sizes with mklibs
INHERIT += "image-mklibs"

#run QA tests on recipes
#INHERIT += "recipe_sanity"

PACKAGE_CLASSES ?= "package_ipk"

# All images build with the distribution get the version package
IMAGE_INSTALL_append = " os-release"
PREFERRED_PROVIDER_os-release = "yogurt-version"

# Move listet checks from ERROR_QA to WARN_QA (defined in insane.bbclass)
ERROR_TO_WARN_QA = "version-going-backwards"
ERROR_QA_remove = "${ERROR_TO_WARN_QA}"
WARN_QA_append = " ${ERROR_TO_WARN_QA}"

# suppress meta-virtualization useless warning when building
# without virtualization distro feature
SKIP_META_VIRT_SANITY_CHECK = "1"
