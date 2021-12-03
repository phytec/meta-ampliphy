SUMMARY = "Secure Key storage install"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/secure-key-storage:"
SRC_URI = " \
    file://physecurekeystorage-install.sh \
"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0500 physecurekeystorage-install.sh ${D}${bindir}/physecurekeystorage-install
}

FILES_${PN} = "\
    ${bindir}/physecurekeystorage-install \
"
