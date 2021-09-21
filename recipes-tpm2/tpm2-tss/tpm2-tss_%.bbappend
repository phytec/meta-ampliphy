DEPENDS += " curl json-c"

PACKAGECONFIG[fapi] = "--enable-fapi"
PACKAGECONFIG += "fapi"

PACKAGES += "fapitools"

FILES_fapitools = "\
    ${sysconfdir}/* \
    ${sysconfdir}/tpm2-tss/* \
    ${sysconfdir}/sysusers.d/* \
"
