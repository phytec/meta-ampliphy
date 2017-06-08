DISTRO_VERSION ??= "UNASSIGNED"
DISTRO_VERSION_mx6 = "i.MX6-PD-pyro"
DISTRO_VERSION_ti33x = "AM335x-PD-pyro"
DISTRO_VERSION_rk3288 = "RK3288-PD-pyro"
VENDOR = "phytec"
TARGET_VENDOR = "-${VENDOR}"

SDK_VENDOR = "-${DISTRO}sdk"
SDK_VERSION := "${@'${DISTRO_VERSION}'.replace('snapshot-${DATE}','snapshot')}"
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
