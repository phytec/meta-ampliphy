FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI += " \
    file://0001-UPSTREAM-opencv-allow-compilation-against-4.5.x.patch \
    file://0004-opencv-resolve-missing-opencv-data-dir-in-yocto-buil.patch \
    file://0001-waylandsink-Prefer-ion-allocator-over-dmabufheaps-al.patch \
"
