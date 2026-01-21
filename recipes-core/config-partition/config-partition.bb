DESCRIPTION = "Populate config partition"
HOMEPAGE = "https://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

inherit deploy
S = "${UNPACKDIR}"

C = "${WORKDIR}/config-partition"

fakeroot do_config_partition () {
        install -d ${C}
        install -d ${C}/rauc
        if echo ${MACHINE_FEATURES} | grep -wq "optee"; then
                install -o teesuppl -g teesuppl -m 0700 -d ${C}/optee
        fi

        tar -czf ${B}/config-partition.tar.gz -C ${C}/ .

        # calculate size of config partition,
        # needs to be at least 2MB for ext4
        size=$(du -s ${C} | awk '{print $1}')
        if [ $size -lt 2048 ]; then size=2048; fi
        mkfs.ext4 -d ${C} ${B}/config-partition.ext4 $size
}
do_config_partition[depends] += " \
        virtual/fakeroot-native:do_populate_sysroot \
        e2fsprogs-native:do_populate_sysroot \
        ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'optee-client:do_populate_sysroot', '', d)} \
"
addtask config_partition

do_deploy () {
        install -m 644 ${B}/config-partition.tar.gz ${DEPLOYDIR}
        install -m 644 ${B}/config-partition.ext4 ${DEPLOYDIR}
}
addtask deploy after do_config_partition
