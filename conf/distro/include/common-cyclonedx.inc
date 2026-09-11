INHERIT += "cyclonedx-export"
CYCLONEDX_SPEC_VERSION = "1.6"

CYCLONEDX_EXPORT_DIR ?= "${DEPLOY_DIR_IMAGE}"
# Try to set meaningful default filenames for both image and non-image recipes
CYCLONEDX_EXPORT_BASENAME ?= "${CYCLONEDX_EXPORT_DIR}/${@d.getVar('IMAGE_NAME') or d.getVar('IMAGE_BASENAME') or d.getVar('PN')}.cyclonedx"
CYCLONEDX_EXPORT_SBOM ?= "${CYCLONEDX_EXPORT_BASENAME}.bom.json"
CYCLONEDX_EXPORT_VEX ?= "${CYCLONEDX_EXPORT_BASENAME}.vex.json"
# Create symlinks for image recipes similar to the image files by default
IMAGE_LINK_NAME ??= ""
CYCLONEDX_EXPORT_SBOM_LINK ?= "${@'${IMAGE_LINK_NAME}.cyclonedx.bom.json' if d.getVar('IMAGE_LINK_NAME') else ''}"
CYCLONEDX_EXPORT_VEX_LINK ?= "${@'${IMAGE_LINK_NAME}.cyclonedx.vex.json' if d.getVar('IMAGE_LINK_NAME') else ''}"

python () {
    recipes = (d.getVar('CYCLONEDX_EXTRA_RUNTIME_RECIPES') or '').split()
    deps = ' '.join('%s:do_populate_cyclonedx' % recipe for recipe in recipes)
    d.appendVarFlag('do_rootfs', 'depends', ' ' + deps)
}
