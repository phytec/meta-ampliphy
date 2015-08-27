SUMMARY = "Machine specific systemd units"

LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/LICENSE;md5=4d92cd373abda3937c2bc47fbc49d690"

PACKAGE_ARCH = "${MACHINE_ARCH}"

PR = "r21"
inherit systemd

NATIVE_SYSTEMD_SUPPORT = "1"
ALLOW_EMPTY_${PN} = "1"

# Don't generate empty -dbg package
PACKAGES = "${PN}"

SRC_URI = " \
    file://eth0.network \
    file://eth1.network \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "file://can0.service", "", d)} \
"

SYSTEMD_SERVICE_${PN} = " \
    ${@bb.utils.contains("MACHINE_FEATURES", "can", "can0.service", "", d)} \
"

do_install() {
    install -d ${D}${systemd_unitdir}/network/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.network); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/network/
    done
    install -d ${D}${systemd_unitdir}/system/
    for file in $(find ${WORKDIR} -maxdepth 1 -type f -name *.service); do
        install -m 0644 "$file" ${D}${systemd_unitdir}/system/
    done
}

# Ship directory "/lib/systemd/system" explicitly in case it is empty. Avoids:
#     QA Issue: systemd-machine-units: Files/directories were installed but not shipped
FILES_${PN}_append = " \
    ${systemd_unitdir}/system/ \
    ${systemd_unitdir}/network/ \
"
