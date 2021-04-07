LOCALVERSION = "-${@legitimize_package_name(d.getVar('DISTRO_VERSION', True))}"
DEPENDS_append_secureboot += "phytec-dev-ca-native"
do_patch_secureboot[depends] += "phytec-dev-ca-native:do_install"

python do_env_append() {
    env_add(d, "boot/initrd",
"""#!/bin/sh
path="/mnt/tftp"

global.bootm.image="${path}/${global.user}-linux-${global.hostname}"

global.bootm.oftree="${path}/${global.user}-oftree-${global.hostname}"
global.bootm.initrd="${path}/${global.user}-phytec-initramfs-image-${global.hostname}.cpio.gz"

global.linux.bootargs.dyn.root="root=/dev/ram0 ip=$eth0.ipaddr:$eth0.serverip:$eth0.gateway:$eth0.netmask:: quiet"
""")
}
