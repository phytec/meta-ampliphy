SUMMARY = "Phytec demo welcome webpage"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

SRC_URI = "\
            https://download.phytec.de/Software/Linux/Applications/demo-welcome-webpage_${PV}.tar.gz;unpack=false;downloadfilename=webpage.tar.gz \
            file://override.conf \
          "
SRC_URI[sha256sum] = "2b0d3b4ca3102eb5de379cd297f92417573545db4f004acb947491e878cb4b69"

S = "${WORKDIR}"

PR = "r0"

# strip leading folder in archive and exclude script sub folder as this is not needed
TAR_ARGS = "--strip-components=1 --exclude='${BPN}-${PV}/scripts'"

do_install () {
    install -d ${D}${servicedir}/http
    # extract webpage archive to /srv/http
    tar --no-same-owner -xpf ${S}/webpage.tar.gz -C ${D}${servicedir}/http \
        ${TAR_ARGS}

    # install a systemd override to open the welcome-demo during system boot on chromium
    install -d ${D}${systemd_system_unitdir}/chromium.service.d
    install -m 0644 ${S}/override.conf ${D}${systemd_system_unitdir}/chromium.service.d/
}

FILES:${PN} = "\
    ${servicedir}/http \
    ${systemd_system_unitdir}/chromium.service.d/override.conf \
"

RDEPENDS:${PN} = "\
    chromium-ozone-wayland \
    chromium-service \
"
