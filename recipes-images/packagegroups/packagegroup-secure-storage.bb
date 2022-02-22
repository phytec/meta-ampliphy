DESCRIPTION = "Packagegroup Secure Key Storage for Kernel keyring access"
LICENSE = "MIT"

inherit packagegroup

# Runtime packages used in 'securestorage-ramdisk-init'
RDEPENDS_${PN} = " \
    util-linux \
    cryptsetup \
    lvm2 \
    kernel-module-dm-integrity \
"
