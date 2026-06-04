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
