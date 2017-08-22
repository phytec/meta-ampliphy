PACKAGECONFIG ??= "sqlite3 \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'pam', 'pam', '', d)} \
                   ${@bb.utils.contains('DISTRO_FEATURES', 'ipv6', 'ipv6', '', d)} \
"
