PACKAGECONFIG[fapi] = "--enable-fapi,--disable-fapi,curl json-c"
PACKAGECONFIG += "fapi"

FILES_${PN} += "\
    ${sysconfdir}/tmpfiles.d \
    ${sysconfdir}/tpm2-tss \
    ${sysconfdir}/sysusers.d \
"
