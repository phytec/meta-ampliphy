INHERIT += "cyclonedx-export"

python () {
    recipes = (d.getVar('CYCLONEDX_EXTRA_RUNTIME_RECIPES') or '').split()
    deps = ' '.join('%s:do_populate_cyclonedx' % recipe for recipe in recipes)
    d.appendVarFlag('do_rootfs', 'depends', ' ' + deps)
}
