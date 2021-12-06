FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

SRC_URI:append = "file://print_issue.sh \
                  file://qt_setup_env.sh \
                  file://base-files.conf \
"
dirs755:append = " ${sysconfdir}/profile.d"

do_fetch[vardeps] += "EMMC_DEV"

parse_fstab() {
    sed -i -e 's/@EMMC_DEV@/${EMMC_DEV}/g' ${WORKDIR}/fstab
}
clean_fstab() {
    # /mnt/config does not exist when using a regular (non-RAUC) image
    sed -i -e '/\/mnt\/config/d' ${WORKDIR}/fstab
}

python do_patch:append() {
    if "rauc" in d.getVar("DISTRO_FEATURES").split():
        bb.build.exec_func("parse_fstab", d)
    else:
        bb.build.exec_func("clean_fstab", d)
}

do_install:append() {
    install -m 0755 ${WORKDIR}/print_issue.sh ${D}${sysconfdir}/profile.d/print_issue.sh
    install -m 0755 ${WORKDIR}/qt_setup_env.sh ${D}${sysconfdir}/profile.d/qt_setup_env.sh
    install -m 0644 ${WORKDIR}/share/dot.profile ${D}${ROOT_HOME}/.profile
    install -m 0644 ${WORKDIR}/share/dot.bashrc ${D}${ROOT_HOME}/.bashrc
    install -Dm 0644 ${WORKDIR}/base-files.conf ${D}${sysconfdir}/tmpfiles.d/base-files.conf
}

do_install_basefilesissue:append() {
    if [ -n "${DISTRO_NAME}" ]; then
        sed -i 's/%h//g' ${D}${sysconfdir}/issue.net
    fi
}
