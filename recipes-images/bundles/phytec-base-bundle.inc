SUMMARY = "PHYTEC rauc bundles from meta-yogurt"
HOMEPAGE = "http://www.phytec.de"

inherit bundle

RAUC_BUNDLE_DESCRIPTION ?= "PHYTEC rauc bundle based on ${DISTRO_VERSION}"

RAUC_BUNDLE_COMPATIBLE ?= "${MACHINE}"

RAUC_BUNDLE_SLOTS ?= "rootfs kernel dtb"

RAUC_SLOT_rootfs[type] ?= "image"
RAUC_SLOT_rootfs[fstype] ?= "ubifs"

RAUC_SLOT_kernel ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_kernel[type] ?= "kernel"

RAUC_SLOT_dtb ?= "${PREFERRED_PROVIDER_virtual/kernel}"
RAUC_SLOT_dtb[type] ?= "file"
RAUC_SLOT_dtb[file] ?= "${@first_dtb(d)}"
def first_dtb(d):
    dtbs = d.getVar('KERNEL_DEVICETREE')
    return dtbs.split()[0]

RAUC_KEY_FILE ?= "${CERT_PATH}/ca.key.pem"
RAUC_CERT_FILE ?= "${CERT_PATH}/ca.cert.pem"
