FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://0001-backend-drm-Fix-ignoring-config-require-input-option.patch \
"
