do_patch_append() {
    import subprocess, os
    # S gets modified which breaks gitsm
    sdir = os.path.join(d.getVar('WORKDIR'), 'git')
    output = subprocess.check_output(["git", "submodule", "update", "--init", "--recursive"], cwd=sdir, stderr=subprocess.STDOUT)
}
