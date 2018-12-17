FILESEXTRAPATHS_prepend := "${THISDIR}/files:"

DEPENDS += "python3-setuptools-scm-native"

SRC_URI +=  "file://config.cfg"

do_patch_append() {
    bb.note("copying config.cfg from meta layer to source dir")
    import shutil
    src = d.getVar('WORKDIR') + "/config.cfg"
    dst = d.getVar('S') + "/rauc_hawkbit/config.cfg"
    shutil.copyfile(src, dst)
}
