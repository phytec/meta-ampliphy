DEPENDS += "${@bb.utils.contains('DISTRO_FEATURES', 'ssh-authentication', 'phytec-dev-ca-native', '', d)}"

do_install:append () {
    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'ssh-authentication', d)}" ]; then
        install -d ${D}${sysconfdir}/ssh
        install -m 0644 ${SSH_CA_PUBKEY} ${D}${sysconfdir}/ssh/
        sed -i -e 's:#PasswordAuthentication yes:PasswordAuthentication no:' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -e 's:#PubkeyAuthentication yes:PubkeyAuthentication yes:' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -e 's:#MaxAuthTries:MaxAuthTries:' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -e 's:#MaxSessions:MaxSessions:' ${D}${sysconfdir}/ssh/sshd_config
        echo "TrustedUserCAKeys ${sysconfdir}/ssh/$(basename ${SSH_CA_PUBKEY})" >> ${D}${sysconfdir}/ssh/sshd_config

        sed -i -E 's/^\s*#?\s*KexAlgorithms\b.*/KexAlgorithms ecdh-sha2-nistp521/; t
        $a KexAlgorithms ecdh-sha2-nistp521' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -E 's/^\s*#?\s*Ciphers\b.*/Ciphers aes256-gcm@openssh.com/; t
        $a Ciphers aes256-gcm@openssh.com' ${D}${sysconfdir}/ssh/sshd_config
        sed -i -E 's/^\s*#?\s*MACs\b.*/MACs hmac-sha2-512/; t
        $a MACs hmac-sha2-512' ${D}${sysconfdir}/ssh/sshd_config
    fi
}
