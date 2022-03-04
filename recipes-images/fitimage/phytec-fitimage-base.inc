SUMMARY = "Phytec's FIT-Image base"
LICENSE = "MIT"

REQUIRED_DISTRO_FEATURES = "secureboot"
inherit features_check

inherit fitimage

FITIMAGE_SLOT_kernel ?=  "${PREFERRED_PROVIDER_virtual/kernel}"
FITIMAGE_SLOT_kernel[type] ?= "kernel"
FITIMAGE_SLOT_kernel[file] ?= "${KERNEL_IMAGETYPE}"

FITIMAGE_SLOT_fdt ?= "${PREFERRED_PROVIDER_virtual/kernel}"
FITIMAGE_SLOT_fdt[type] ?= "fdt"
FITIMAGE_SLOT_fdt[file] ?= "${@os.path.basename(d.getVar('KERNEL_DEVICETREE').split()[0])}"

FITIMAGE_SLOT_fdto ?= "${PREFERRED_PROVIDER_virtual/kernel}"
FITIMAGE_SLOT_fdto[type] ?= "fdto"
FITIMAGE_SLOT_fdto[file] ?= "${@' '.join(os.path.basename(dtb) for dtb in d.getVar('KERNEL_DEVICETREE').split() if dtb.endswith('.dtbo'))}"

def readfull_bin(path):
    content = None
    with open(path, 'rb') as fd:
        content = fd.read()
    return content


python do_unpack:append() {
    import hashlib
    hash_sha256 = hashlib.sha256(readfull_bin(d.getVar('FITIMAGE_SIGN_KEY_PATH'))).hexdigest()
    if hash_sha256 == '1e3eb95fe6a7d1e45db761bff6eedafb9291661480e1a1ad10eb6f5b8b9961c1' or hash_sha256 ==  '6f92252aab834bbe8090e92c44f051b2c40db8e3953c8c26c04c14e7ae2db7d8':
        bb.warn("!! CRITICAL SECURITY WARNING: You're using Phytec's Development Keyring for Secure Boot in the fit-image. Please create your own keys!!")
}
do_unpack[depends] += "phytec-dev-ca-native:do_install"
