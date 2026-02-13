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
    ${@'libubootenv-bin u-boot-tools-mkimage' if (d.getVar('PREFERRED_PROVIDER_virtual/bootloader', True) or '').startswith('u-boot') else ''} \
"
