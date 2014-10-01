#yogurt image to test systemd and gnome

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

IMAGE_PREPROCESS_COMMAND = "rootfs_update_timestamp ;"

EXTRA_IMAGE_FEATURES += "splash"

DISTRO_UPDATE_ALTERNATIVES ??= ""
ROOTFS_PKGMANAGE_PKGS ?= '${@base_conditional("ONLINE_PACKAGE_MANAGEMENT", "none", "", "${ROOTFS_PKGMANAGE} ${DISTRO_UPDATE_ALTERNATIVES}", d)}'

CONMANPKGS ?= "connman connman-plugin-loopback connman-plugin-ethernet connman-plugin-wifi"
CONMANPKGS_libc-uclibc = ""

IMAGE_INSTALL += " \
    packagegroup-basic \
    ${CONMANPKGS} \
    ${ROOTFS_PKGMANAGE_PKGS} \
    update-alternatives-opkg \
    systemd-analyze \
    xinput-calibrator \
    systemd-analyze \
    packagegroup-gnome \
    packagegroup-gnome-apps \
    packagegroup-gnome-themes \
    packagegroup-gnome-xserver-base \
    packagegroup-core-x11-xserver \
    packagegroup-gnome-fonts \
"

IMAGE_DEV_MANAGER   = "udev"
IMAGE_INIT_MANAGER  = "systemd"
IMAGE_INITSCRIPTS   = " "
IMAGE_LOGIN_MANAGER = "busybox shadow"

export IMAGE_BASENAME = "systemd-GNOME-image"

inherit image
