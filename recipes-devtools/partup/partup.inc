SUMMARY = "System initialization program"
HOMEPAGE = "https://github.com/phytec/partup"

LICENSE = "GPL-3.0-or-later"
LIC_FILES_CHKSUM = "file://LICENSE;md5=5b4473596678d62d9d83096273422c8c"

inherit meson pkgconfig

DEPENDS = "glib-2.0 libyaml parted"
RDEPENDS_${PN} += " \
    tar \
    e2fsprogs-resize2fs \
    e2fsprogs-mke2fs \
    dosfstools \
    util-linux-sfdisk \
    util-linux-lsblk \
    util-linux-mount \
"
