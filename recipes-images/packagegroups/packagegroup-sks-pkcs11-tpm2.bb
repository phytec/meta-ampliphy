DESCRIPTION = "Packagegroup Secure Key Storage for PKCS11 with TPM2."
LICENSE = "MIT"

PACKAGE_ARCH = "${TUNE_PKGARCH}"

inherit packagegroup

SUMMARY:packagegroup-pkcs11-tpm2 = "PKCS11 with TPM 2.0 support"

RDEPENDS:${PN} = " \
    opensc \
    libp11 \
    tpm2-pkcs11 \
    pkcs11-provider \
"
