DESCRIPTION = "U-Boot scripts for booting Ampliphy"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=3da9cfbcb788c80a0384361b4de20420"

inherit deploy

SRC_URI = " \
    file://mmc_boot.cmd \
    file://mmc_boot_fit.cmd \
    file://eth_boot.cmd \
    file://spi_boot.cmd \
    file://boot.its.in \
"

S = "${WORKDIR}"
DEPENDS = "u-boot-mkimage-native dtc-native"

MMC_BOOT_SCRIPT ?= "mmc_boot.cmd"
MMC_BOOT_SCRIPT:secureboot ?= "mmc_boot_fit.cmd"


do_compile() {
    for script in *.cmd ; do
        sed -e "s/@@BOOTCOMMAND_FILE@@/${script}/" "${S}/boot.its.in" > ${S}/boot.its
        mkimage -C none -A ${UBOOT_ARCH} -f ${S}/boot.its ${S}/${script}.scr.uimg
    done
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 ${S}/${MMC_BOOT_SCRIPT}.scr.uimg ${DEPLOYDIR}/boot.scr.uimg
    install -m 0644 ${S}/eth_boot.cmd.scr.uimg ${DEPLOYDIR}/eth_boot.scr.uimg
    install -m 0644 ${S}/spi_boot.cmd.scr.uimg ${DEPLOYDIR}/spi_boot.scr.uimg
}

addtask deploy after do_install before do_build
