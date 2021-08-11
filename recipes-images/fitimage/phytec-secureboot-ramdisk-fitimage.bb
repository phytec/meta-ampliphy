SUMMARY = "Phytec's FIT-Image with secureboot ramdisk"
DESCRIPTION = "FIT-Image with a single kernel, devicetree and secureboot ramdisk"
LICENSE = "MIT"

REQUIRED_DISTRO_FEATURES = "secureboot"
inherit features_check

inherit fitimage

FITIMAGE_SLOTS ?= "kernel fdt ramdisk"

FITIMAGE_SLOT_kernel ?=  "${PREFERRED_PROVIDER_virtual/kernel}"
FITIMAGE_SLOT_kernel[type] ?= "kernel"
FITIMAGE_SLOT_kernel[file] ?= "${KERNEL_IMAGETYPE}"

FITIMAGE_SLOT_fdt ?= "${PREFERRED_PROVIDER_virtual/kernel}"
FITIMAGE_SLOT_fdt[type] ?= "fdt"
FITIMAGE_SLOT_fdt[file] ?= "${@os.path.basename(d.getVar('KERNEL_DEVICETREE').split()[0])}"

FITIMAGE_SLOT_ramdisk ?= "phytec-secureboot-ramdisk-image"
FITIMAGE_SLOT_ramdisk[type] ?= "ramdisk"
FITIMAGE_SLOT_ramdisk[fstype] ?= "cpio.gz"

do_deploy:append() {
    # check for problematic certificate setups
    shasum=$(sha256sum "${FITIMAGE_SIGN_KEY_PATH}" | cut -d' ' -f1)
    if [ "$shasum" = "fda2863c40b971a6909ff5c278d27988dc14361d10920299c51e9a1a163984dc" ]; then
          bbwarn "!! CRITICAL SECURITY WARNING: You're using Phytec's Development Keyring for Secure Boot in the fit-image. Please create your own!!"
    fi
}
