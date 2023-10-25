FILESEXTRAPATHS:prepend := "${THISDIR}/${PN}:"

python do_optee_warning() {
    bb.warn("OP-TEE support is experimental and not ready for production use")
}
addtask optee_warning before do_deploy
do_optee_warning[nostamp] = "1"
