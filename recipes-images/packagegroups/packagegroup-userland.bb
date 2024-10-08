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
    kbd \
    kbd-keymaps \
    rpm \
    linuxptp \
    wget \
    ${@bb.utils.contains_any('PREFERRED_PROVIDER_virtual/bootloader', 'u-boot u-boot-phytec u-boot-imx u-boot-phytec-ti', 'libubootenv-bin',     '', d)} \
"
