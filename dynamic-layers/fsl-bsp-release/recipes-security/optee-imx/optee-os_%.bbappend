FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}:"

python do_optee_warning() {
    bb.warn("OP-TEE support is experimental and not ready for production use")
}
addtask optee_warning before do_deploy
do_optee_warning[nostamp] = "1"

# Configure the in-tree trusted keys TA (from optee-os/ta/trusted_keys) as an
# early TA so OP-TEE loads it on start. This is required for the trusted keys
# kernel module.
EXTRA_OEMAKE_append = " CFG_IN_TREE_EARLY_TAS=trusted_keys/f04a0fe7-1f5d-4b9b-abf7-619b85b4ce8c "
