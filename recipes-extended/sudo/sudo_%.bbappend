do_install:append(){
    # Make sudo available to users in the group sudo
    if [ "${@bb.utils.filter('DISTRO_FEATURES', 'protectionshield', d)}" ]; then
        sed -i 's/# \(%sudo\s\+ALL=(ALL:ALL) ALL\)/\1/' ${D}/${sysconfdir}/sudoers
    fi
}
