DEPENDS += " curl json-c"

PACKAGECONFIG[fapi] = "--enable-fapi"
PACKAGECONFIG += "fapi"

FILES:fapitools = "\
    ${sysconfdir}/* \
    ${sysconfdir}/tpm2-tss/* \
    ${sysconfdir}/sysusers.d/* \
"

PACKAGES += "fapitools"
