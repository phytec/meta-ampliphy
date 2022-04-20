FILESEXTRAPATHS:prepend := "${THISDIR}/${BPN}:"

set_password_rules(){

    if [ "${@bb.utils.filter('IMAGE_FEATURES', 'debug-tweaks',d)}" ]; then
        bbwarn "!! Please deactivate debug-tweaks for the Protectionshield Level"
    fi
    if [ "${@bb.utils.filter('IMAGE_FEATURES', 'allow-empty-password', d)}" ]; then
        bbwarn "!! Please deactivate allow-empty-password for the Protectionshield Level"
    fi
    if [ "${@bb.utils.filter('IMAGE_FEATURES', 'empty-root-password',d)}" ]; then
        bbwarn "!! Please deactivate debug-tweaks for the Protectionshield Level"
    fi
    sed -i -e 's:PasswordAuthentication no:PasswordAuthentication yes:' ${D}${sysconfdir}/ssh/sshd_config
    sed -i -e 's:#PasswordAuthentication yes:PasswordAuthentication yes:' ${D}${sysconfdir}/ssh/sshd_config
    sed -i -e 's:PermitEmptyPasswords yes:PermitEmptyPasswords no:' ${D}${sysconfdir}/ssh/sshd_config
    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'pam', d)}" ]; then
        sed -i -e 's:#UsePAM no:UsePAM yes:' ${D}${sysconfdir}/ssh/sshd_config
        echo "AuthenticationMethods keyboard-interactive" >> ${D}${sysconfdir}/ssh/sshd_config
    else
        sed -i -e 's:UsePAM yes:UsePAM no:' ${D}${sysconfdir}/ssh/sshd_config
    fi
}

do_install:append:shieldlow() {
    set_password_rules
}

do_install:append:shieldmedium() {
    set_password_rules
}

do_install:append:shieldhigh() {
    if [ "${@bb.utils.filter('IMAGE_FEATURES', 'allow-root-login',d)}" ]; then
        bbwarn "!! Please deactivate allow-root-login for the Protectionshield Level High"
    fi

    set_password_rules
    sed -i -e 's:PermitRootLogin yes:PermitRootLogin no:' ${D}${sysconfdir}/ssh/sshd_config
}
