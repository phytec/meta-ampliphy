FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append:mx8mp-nxp-bsp = "\
    file://0001-plugins-Remove-videoconverter-plugin.patch \
"
