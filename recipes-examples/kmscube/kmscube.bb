CRIPTION = "Demo application to showcase 3D graphics on Mali-T760 using kms and gbm"
HOMEPAGE = "https://github.com/robclark/kmscube"
LICENSE = "BSD"
LIC_FILES_CHKSUM = "file://kmscube.c;beginline=1;endline=23;md5=8b309d4ee67b7315ff7381270dd631fb"

DEPENDS = "virtual/egl virtual/libgles2 libdrm libgbm"

inherit autotools pkgconfig

PR = "r5"
SRCREV = "8c6a20901f95e1b465bbca127f9d47fcfb8762e6"

SRC_URI = "git://github.com/robclark/kmscube.git"
SRC_URI += " file://0001-Use-GBM-platform-specific-functions.patch \
	file://0001-Add-rockchip-to-modules.patch"

S = "${WORKDIR}/git"

INSANE_SKIP_kmscube += "dev-deps"

COMPATIBLE_MACHINE = "rk3288"
