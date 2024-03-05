DESCRIPTION = "Userland softwareservices found in all Phytec BSPs"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} = " \
    gdbserver \
    strace \
    openssh \
    openssh-sftp-server \
    rsync \
    htop \
    crda \
    kbd \
    kbd-keymaps \
    opkg \
    opkg-utils \
    linuxptp \
    wget \
    ${@bb.utils.contains_any('PREFERRED_PROVIDER_virtual/bootloader', 'u-boot u-boot-imx u-boot-ti', 'libubootenv-bin',     '', d)} \
"
