FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:ti33x = " \
    file://0001-Revert-require-GL_EXT_unpack_subimage-commit.patch \
"
