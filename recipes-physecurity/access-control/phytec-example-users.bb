SUMMARY = "User configuration for PHYTEC Boards"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

REQUIRED_DISTRO_FEATURES = "protectionshield"
inherit features_check
inherit useradd
inherit systemd

SYSTEMD_SERVICE:${PN} = "phytec-example-users.service"

SRC_URI = " \
    file://99-phyapix.rules \
    file://setpassword.sh \
    file://phytec-example-users.service \
"

S = "${WORKDIR}"

PROTECTIONSHIELD_PHYADMINUSER_PASSWORD ??= ''
#encrypted phyadmin with password phyadmin
PROTECTIONSHIELD_PHYADMINUSER_PASSWORD:shieldlow ??= '-p 11jiH9dJQzEgY'

PROTECTIONSHIELD_PHYUSER_PASSWORD ??= ''
#encrypted phyuser with password phyuser
PROTECTIONSHIELD_PHYUSER_PASSWORD:shieldlow ??= '-p V7IbT.QGVxEhU'

PROTECTIONSHIELD_PHYREADUSER_PASSWORD ??= ''
#encrypted phyreaduser with password phyreaduser
PROTECTIONSHIELD_PHYREADUSER_PASSWORD:shieldlow ??= '-p 8I7kGtsDscIGI'

GROUPADD_PARAM:${PN} = "\
    --system phyapix; \
    ${@bb.utils.contains("MACHINE_FEATURES", "tpm2", "--system tss", "", d)} \
"

USERADD_PACKAGES = "${PN}"

USERADD_PARAM:${PN} = " \
    --uid 1200 --system \
    --shell /bin/sh \
    --create-home \
    --groups tty,phyapix,sudo,root${@bb.utils.contains("MACHINE_FEATURES", "tpm2",",tss","",d)}\
    ${PROTECTIONSHIELD_PHYADMINUSER_PASSWORD} \
    --user-group phyadmin; \
    --uid 1201 --system \
    --shell /bin/sh \
    --create-home \
    --groups tty,phyapix${@bb.utils.contains("MACHINE_FEATURES", "tpm2",",tss","",d)}\
    ${PROTECTIONSHIELD_PHYUSER_PASSWORD} \
    --user-group phyuser; \
    --uid 1202 --system \
    --shell /bin/sh \
    --groups tty \
    ${PROTECTIONSHIELD_PHYREADUSER_PASSWORD} \
    --create-home \
    --user-group phyreaduser \
"

do_install() {
    install -d ${D}${sysconfdir}/udev/rules.d
    install -d ${D}${sysconfdir}/udev/scripts
    install -m 0644 ${WORKDIR}/99-phyapix.rules ${D}${sysconfdir}/udev/rules.d/

    install -d ${D}${systemd_unitdir}/system/
    install -m 0644 ${WORKDIR}/phytec-example-users.service ${D}${systemd_unitdir}/system/

    install -d ${D}${bindir}
    install -m 0755 ${S}/setpassword.sh ${D}${bindir}/setpassword
}

do_install:append:shieldhigh(){
    sed -i -e 's:SetRootPassword=yes:SetRootPassword=no:' ${D}${bindir}/setpassword
}

RDEPENDS:${PN} = " \
    sudo \
"
FILES:${PN} += " \
    ${systemd_unitdir}/system/phytec-example-users.service \
"

# Prevents do_package failures with:
# debugsources.list: No such file or directory:
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"
