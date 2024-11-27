FILESEXTRAPATHS:prepend := "${THISDIR}/files:"

SRC_URI += "file://filter.json"

PACKAGECONFIG += "make-icudata"

PACKAGECONFIG:pn-icu-native += " make-icudata"
