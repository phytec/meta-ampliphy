FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

SRC_URI_append = " \
    file://0001-backend-drm-Fix-ignoring-config-require-input-option.patch \
"