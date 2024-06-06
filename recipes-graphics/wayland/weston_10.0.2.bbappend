FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:am57xx = " \
    file://0001-backend-drm-Select-plane-based-on-current-attached-C.patch \
    file://0001-Revert-require-GL_EXT_unpack_subimage-commit.patch \
    file://0001-backend-drm-Pre-sort-plane-list-by-zpos.patch \
    file://0002-backend-drm-fix-plane-sorting.patch \
    file://0003-drm-backend-Remember-to-set-the-zpos-for-the-scanout.patch \
    file://0004-backend-drm-Assign-plane_idx-by-plane-list-order.patch \
"
