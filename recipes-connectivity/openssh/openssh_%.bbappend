DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'ssh-authentication', 'phytec-dev-ca-native', '', d)}"

do_install:append () {
    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'ssh-authentication', d)}" ]; then
        install -d ${D}${sysconfdir}/ssh
        install -m 0644 ${SSH_CA_PUBKEY} ${D}${sysconfdir}/ssh/
        sed -i -e 's:#PasswordAuthentication yes:PasswordAuthentication no:' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -e 's:#PubkeyAuthentication yes:PubkeyAuthentication yes:' ${D}${sysconfdir}/ssh/sshd_config
        echo "TrustedUserCAKeys ${sysconfdir}/ssh/$(basename ${SSH_CA_PUBKEY})" >> ${D}${sysconfdir}/ssh/sshd_config
    fi
}
