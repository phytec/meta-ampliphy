FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = "file://print_issue.sh \
                  file://base-files.conf \
                  file://20-bootpart.rules \
                  file://isbootpart \
"

dirs755:append = " ${sysconfdir}/profile.d"

do_fetch[vardeps] += "EMMC_DEV"

parse_fstab() {
    if echo "${MACHINE_FEATURES}" | grep -q "emmc"; then
        sed -i \
            -e 's/@CONFIG_DEV@/\/dev\/mmcblk${EMMC_DEV}p3/g' \
            -e 's/@CONFIG_DEV_TYPE@/auto/g' \
            ${WORKDIR}/fstab
    else
        sed -i \
            -e 's/@CONFIG_DEV@/ubi0:config/g' \
            -e 's/@CONFIG_DEV_TYPE@/ubifs/g' \
            ${WORKDIR}/fstab
    fi
}
clean_fstab() {
    # /mnt/config does not exist when using a regular (non-RAUC) image
    sed -i -e '/\/mnt\/config/d' ${WORKDIR}/fstab
}

do_patch[postfuncs] += " \
    ${@bb.utils.contains('DISTRO_FEATURES', 'rauc-appfs', '', 'fstab_delete_appfs', d)} \
    bootpart_rules_bindir \
"

fstab_delete_appfs() {
    sed -i -e '/\/mnt\/app/d' ${WORKDIR}/fstab
}

bootpart_rules_bindir() {
    sed -i -e 's#@BINDIR@#${bindir}#g' ${WORKDIR}/20-bootpart.rules
}

python do_patch:append() {
    if "rauc" in d.getVar("DISTRO_FEATURES").split():
        bb.build.exec_func("parse_fstab", d)
    else:
        bb.build.exec_func("clean_fstab", d)
}

do_install:append() {
    install -d ${D}/mnt/config
    install -d ${D}/mnt/app
    install -m 0755 ${WORKDIR}/print_issue.sh ${D}${sysconfdir}/profile.d/print_issue.sh
    install -m 0644 ${WORKDIR}/share/dot.profile ${D}${ROOT_HOME}/.profile
    install -m 0644 ${WORKDIR}/share/dot.bashrc ${D}${ROOT_HOME}/.bashrc
    install -Dm 0644 ${WORKDIR}/base-files.conf ${D}${sysconfdir}/tmpfiles.d/base-files.conf
    install -d ${D}${sysconfdir}/udev/rules.d
    install -m 0644 ${WORKDIR}/20-bootpart.rules ${D}${sysconfdir}/udev/rules.d
    install -d ${D}${bindir}
    install -m 0755 ${WORKDIR}/isbootpart ${D}${bindir}
}

do_install_basefilesissue:append() {
    if [ -n "${DISTRO_NAME}" ]; then
        sed -i 's/%h//g' ${D}${sysconfdir}/issue.net
    fi
}

FILES:${PN} += " \
    /mnt/config \
    /mnt/app \
    ${bindir} \
    ${sysconfdir}/udev/rules.d \
"
