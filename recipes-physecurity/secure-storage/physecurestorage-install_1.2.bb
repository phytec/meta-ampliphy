SUMMARY = "Secure storage install file integrity and encryption"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

FILESEXTRAPATHS_prepend := "${THISDIR}/secure-storage:"
SRC_URI = " \
    file://physecurestorage-install.sh \
"

S = "${WORKDIR}"

do_install() {
    install -d ${D}${bindir}
    install -m 0500 physecurestorage-install.sh ${D}${bindir}/physecurestorage-install
}

FILES_${PN} = "\
    ${bindir}/physecurestorage-install \
"
