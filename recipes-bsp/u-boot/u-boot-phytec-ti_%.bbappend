FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append:k3:secureboot = " \
    file://fit.cfg \
"
