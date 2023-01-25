FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://filter.json"

PACKAGECONFIG += "make-icudata"
