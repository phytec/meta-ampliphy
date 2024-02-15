SUMMARY = "Combined image of tiboot3.bin, tispl.bin and u-boot.img"
LICENSE = "MIT"

inherit deploy

do_compile[depends] += "virtual/bootloader:do_deploy"
do_compile[mcdepends] += "mc::k3r5:virtual/bootloader:do_deploy"

do_compile() {
    dd if=${DEPLOY_DIR_IMAGE}/tiboot3.bin of=${B}/ti-boot-rauc.img count=1024 conv=fsync
    dd if=${DEPLOY_DIR_IMAGE}/tispl.bin of=${B}/ti-boot-rauc.img seek=1024 count=3072 conv=fsync
    dd if=${DEPLOY_DIR_IMAGE}/u-boot.img of=${B}/ti-boot-rauc.img seek=5120 count=3072 conv=fsync
}

do_deploy() {
    install -m 644 ${B}/ti-boot-rauc.img ${DEPLOYDIR}
}
addtask deploy after do_compile
