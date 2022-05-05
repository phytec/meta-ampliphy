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
"
