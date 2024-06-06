FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:am57xx = " \
    file://0001-gstdrmallocator-Add-DRM-allocator-support.patch \
    file://0002-kmssink-Add-omapdrm-and-tidss-in-the-list-of-drivers.patch \
"
