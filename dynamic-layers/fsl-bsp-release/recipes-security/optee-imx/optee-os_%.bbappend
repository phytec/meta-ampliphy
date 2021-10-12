FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

# Configure the in-tree trusted keys TA (from optee-os/ta/trusted_keys) as an
# early TA so OP-TEE loads it on start. This is required for the trusted keys
# kernel module.
EXTRA_OEMAKE:append_trustedtee = " CFG_IN_TREE_EARLY_TAS=trusted_keys/f04a0fe7-1f5d-4b9b-abf7-619b85b4ce8c"
