FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

SRC_URI:append = " \
    file://network.sh \
    file://timesync.sh \
    file://provisioninginit.sh \
    file://smartcard.sh \
    ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'file://opteeclient.sh', '', d)} \
    file://securestorageinit.sh \
"

# be set in the machine configuration.
SKS_PATH ??= "/dev/mmcblk${EMMC_DEV}p1"
CONFIG_DEV ??= "/dev/mmcblk${EMMC_DEV}p3"
CONFIG_MOUNTPATH ??= "/mnt/config"

do_varchange() {
    sed -i \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    ${UNPACKDIR}/provisioninginit.sh

    sed -i \
    -e 's:@SKS_PATH@:${SKS_PATH}:g' \
    -e 's:@CONFIG_DEV@:${CONFIG_DEV}:g' \
    -e 's:@CONFIG_MOUNTPATH@:${CONFIG_MOUNTPATH}:g' \
    ${UNPACKDIR}/securestorageinit.sh
}
addtask varchange after do_patch and before do_install

do_install:append() {
    # network
    install -m 0755 ${UNPACKDIR}/network.sh ${D}/init.d/10-network

    # timesync
    install -m 0755 ${UNPACKDIR}/timesync.sh ${D}/init.d/12-timesync

    # smartcard
    install -m 0755 ${UNPACKDIR}/smartcard.sh ${D}/init.d/13-smartcard

    # optee
    if [ -f ${UNPACKDIR}/opteeclient.sh ]; then
        install -m 0755 ${UNPACKDIR}/opteeclient.sh ${D}/init.d/14-opteeclient
    fi

    # provisioninginit
    install -m 0755 ${UNPACKDIR}/provisioninginit.sh ${D}/init.d/98-provisioninginit

    # securestorageinit
    install -m 0755 ${UNPACKDIR}/securestorageinit.sh ${D}/init.d/98-securestorageinit

    # remove node
    rm ${D}/dev/console
}

PACKAGES =+ "\
    initramfs-module-finish \
    initramfs-module-network \
    initramfs-module-timesync \
    initramfs-module-provisioninginit \
    initramfs-module-smartcard \
    ${@bb.utils.contains("MACHINE_FEATURES", "optee", "initramfs-module-optee", "", d)}\
    initramfs-module-securestorage \
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

SUMMARY:initramfs-module-smartcard = "start pcscs-lite for smartcard support"
RDEPENDS:initramfs-module-smartcard = "${PN}-base pcsc-lite opensc"
FILES:initramfs-module-smartcard = "/init.d/13-smartcard"

SUMMARY:initramfs-module-optee = "start tee-supplicant for optee"
RDEPENDS:initramfs-module-optee = "${PN}-base optee-client"
FILES:initramfs-module-optee = "/init.d/14-opteeclient"

SUMMARY:initramfs-module-provisioninginit = "initramfs support PHYTEC provisioning of devices"
RDEPENDS:initramfs-module-provisioninginit = "${PN}-base"
FILES:initramfs-module-provisioninginit = "/init.d/98-provisioninginit"

SUMMARY:initramfs-module-securestorage = "initramfs support PHYTEC secure storage of devices"
RDEPENDS:initramfs-module-securestorage = "${PN}-base"
FILES:initramfs-module-securestorage = "/init.d/98-securestorageinit"
