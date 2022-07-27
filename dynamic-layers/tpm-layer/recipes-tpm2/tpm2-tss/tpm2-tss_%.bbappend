FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

PACKAGECONFIG[fapi] = "--enable-fapi,--disable-fapi,curl json-c"
PACKAGECONFIG += "fapi"

SRC_URI += "\
    file://0001-dist-fapi-config-Set-Keystore-to-mnt-config-tpm-tss.patch \
    file://0002-dist-tmpfiles.d-tpm2-tss-fapi.conf.in-Set-keystore-p.patch \
"

FILES_${PN} += "\
    ${sysconfdir}/tmpfiles.d \
    ${sysconfdir}/tpm2-tss \
    ${sysconfdir}/sysusers.d \
"
