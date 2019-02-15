do_patch_append() {
    import subprocess, os
    # S gets modified which breaks gitsm
    sdir = os.path.join(d.getVar('WORKDIR'), 'git')
    output = subprocess.check_output(["git", "submodule", "update", "--init", "--recursive"], cwd=sdir, stderr=subprocess.STDOUT)
    # hack around some build errors
    import shutil
    shutil.rmtree(sdir + '/edgelet/hsm-sys/azure-iot-hsm-c/deps/c-shared/inc/azure_c_shared_utility/windowsce/', ignore_errors=True)
    shutil.rmtree(sdir + '/edgelet/hsm-sys/azure-iot-hsm-c/deps/utpm/deps/c-utility/inc/azure_c_shared_utility/windowsce/', ignore_errors=True)
}
