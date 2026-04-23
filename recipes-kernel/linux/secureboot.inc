# Loaded from linux-phytec%.bbappend only when secureboot is in
# DISTRO_FEATURES, so everything here applies unconditionally.

inherit signing-helpers

SRC_URI:append = " \
    file://fs_encryption.cfg \
    file://trustedkey-base.cfg \
    ${@bb.utils.contains('MACHINE_FEATURES', 'tpm2', 'file://trustedkey-tpm.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'caam', 'file://trustedkey-caam.cfg', '', d)} \
    ${@bb.utils.contains('MACHINE_FEATURES', 'optee', 'file://trustedkey-tee.cfg', '', d)} \
"

do_assemble_fitimage:prepend() {
    if echo "${UBOOT_SIGN_KEYDIR}" | grep -q "pkcs11:"; then
        setup_pkcs11_env
    fi
}

do_assemble_fitimage_initramfs:prepend() {
    if echo "${UBOOT_SIGN_KEYDIR}" | grep -q "pkcs11:"; then
        setup_pkcs11_env
    fi
}

do_deploy:append() {
    if echo ${KERNEL_IMAGETYPES} | grep -wq "fitImage"; then
        if [ -n "${INITRAMFS_IMAGE}" -a "${INITRAMFS_IMAGE_BUNDLE}" != "1" ]; then
            # Replace the non-initramfs fitImage symlinks created by the
            # BSP's do_deploy:append: with secureboot active, fitImage must
            # be the signed initramfs-bundled image.
            rm -f "${DEPLOYDIR}/fitImage"
            rm -f "${DEPLOYDIR}/fitImage.its"
            ln -snf fitImage-${INITRAMFS_IMAGE_NAME}-${KERNEL_FIT_NAME}${KERNEL_FIT_BIN_EXT} "${DEPLOYDIR}/fitImage"
            ln -snf fitImage-its-${INITRAMFS_IMAGE_NAME}-${KERNEL_FIT_NAME}.its "${DEPLOYDIR}/fitImage.its"
        fi
    fi
}
