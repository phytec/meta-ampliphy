DESCRIPTION = "This recipes deploys an HTML5 application release to the target \
root filesystem. It combines a node.js server application and a browser client \
Application."
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SRC_URI = " \
    ftp://ftp.phytec.de/pub/Software/Linux/BSP-Yocto-HTML5/${PN}/${PN}-v${PV}.tar.gz;unpack=false \
    file://phytec-node-server.service \
"
SRC_URI[md5sum] = "623b6c4677bb1ad13c8c421c0b194040"
SRC_URI[sha256sum] = "443052543b5795520365cace52bc02cc91580b3b71577e9e415f2a990481a462"

inherit allarch systemd

SYSTEMD_SERVICE_${PN} = "phytec-node-server.service"

#install process is similar to bin_package.bbclass
# Skip the unwanted steps
do_configure[noexec] = "1"
do_compile[noexec] = "1"

PREFIX = "/"

# Install the files to ${D}${PREFIX}
do_install () {
    mkdir -p ${D}${PREFIX}
    tar --no-same-owner -xpf ${WORKDIR}/${PN}-v${PV}.tar.gz -C ${D}${PREFIX}
    install -Dm 0644 ${WORKDIR}/phytec-node-server.service ${D}${systemd_system_unitdir}/phytec-node-server.service
}

FILES_${PN} = "/"
INSANE_SKIP_${PN} = "file-rdeps"
