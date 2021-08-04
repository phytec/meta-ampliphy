RDEPENDS:${PN} += "nativesdk-python3-json"

# needed for a working SDK
# without we will get an error like:
#     .../sysroots/x86_64-phytecsdk-linux/usr/bin/qmlcachegen: not found
RDEPENDS:${PN} += "nativesdk-qtdeclarative-tools"
