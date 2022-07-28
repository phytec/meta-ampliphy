FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://network.sh \
    file://timesync.sh \
    file://provisioninginit.sh \
"

# be set in the machine configuration.
SKS_PATH ??= "/dev/mmcblk${EMMC_DEV}p1"
SKS_MOUNTPATH ??= "/mnt_secrets"
CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"

do_varchange() {
    sed -i \
    -e 's:@SKS_PATH@:${SKS_PATH}:g' \
    -e 's:@SKS_MOUNTPATH@:${SKS_MOUNTPATH}:g' \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    ${WORKDIR}/provisioninginit.sh
}
addtask varchange after do_patch and before do_install

do_install:append() {
    # network
    install -m 0755 ${WORKDIR}/network.sh ${D}/init.d/10-network

    # timesync
    install -m 0755 ${WORKDIR}/timesync.sh ${D}/init.d/12-timesync

    # provisioninginit
    install -m 0755 ${WORKDIR}/provisioninginit.sh ${D}/init.d/98-provisioninginit

    # remove node
    rm ${D}/dev/console
}

PACKAGES =+ "\
    initramfs-module-finish \
    initramfs-module-network \
    initramfs-module-timesync \
    initramfs-module-provisioninginit \
"

SUMMARY:initramfs-module-finish = "initramfs finish switch root"
RDEPENDS:initramfs-module-finish = "${PN}-base"
FILES:initramfs-module-finish = "/init.d/99-finish"

SUMMARY:initramfs-module-network = "initramfs support for network configuration"
RDEPENDS:initramfs-module-network = "${PN}-base iproute2 dhcpcd openssh"
FILES:initramfs-module-network = "/init.d/10-network"

SUMMARY:initramfs-module-timesync = "initramfs support for time synchronisation"
RDEPENDS:initramfs-module-timesync = "${PN}-base chrony"
FILES:initramfs-module-timesync = "/init.d/12-timesync"

SUMMARY:initramfs-module-provisioninginit = "initramfs support PHYTEC provisioning of devices"
RDEPENDS:initramfs-module-provisioninginit = "${PN}-base"
FILES:initramfs-module-provisioninginit = "/init.d/98-provisioninginit"
