# SPDX-License-Identifier: MIT
# Copyright 2022 BG Networks, Inc.
# Copyright (C) 2024 Savoir-faire Linux Inc. (<www.savoirfairelinux.com>).
# Copyrirght (C) 2024 Phytec Messtechnik GmbH (<www.phytec.de>).

# SBOM CycloneDX Creator for the target
# This classes integrates SBOM CycloneDX Creator
# based on the https://github.com/savoirfairelinux/meta-cyclonedx

# Usage:
# INHERIT += sbom-cyclonedx
#

CYCLONEDX_EXPORT_TMP ??= "${LOG_DIR}/sbom-cyclonedx"
CYCLONEDX_EXPORT_COMPONENT_FILE ??= "${PN}-${PV}.json"
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"
# Add variable values to the property array of CycloneDX SBOM
CYCLONEDX_EXPORT_PROPERTIES ??= "SRC_URI SRCREV"

CYCLONEDX_WITH_BUILDINFOS ??="0"
CYCLONEDX_WITH_NATIVE ??="0"

SPDX_ORG ??= "OpenEmbedded ()"
SPDX_SUPPLIER ??= "Organization: ${SPDX_ORG}"

python do_cyclonedx_component() {
    sbom = {
        "components": []
    }
    for comp in generate_packages_list(d):
        sbom["components"].append(comp)

    path = d.getVar("CYCLONEDX_EXPORT_TMP")
    if not os.path.exists(path):
        bb.utils.mkdirhier(path)
    sbom_file = os.path.join(path, d.getVar("CYCLONEDX_EXPORT_COMPONENT_FILE"))

    write_json(sbom_file, sbom)
}
addtask do_cyclonedx_component after do_packagedata before do_rm_work
do_cyclonedx_component[nostamp] = "1"
do_cyclonedx_component[rdeptask] += "do_unpack"
do_cyclonedx_component[rdeptask] += "do_packagedata"

python do_cyclonedx_image() {
    import os.path
    import uuid
    from datetime import datetime, timezone
    import os
    from pathlib import Path

    timestamp = datetime.now(timezone.utc).isoformat()
    # Generate unique serial numbers for sbom
    sbom_serial_number = str(uuid.uuid4())

    product_name = "{}-{}".format(d.getVar("IMAGE_BASENAME"),d.getVar("MACHINE"))
    product_version = d.getVar("DISTRO_VERSION")
    product_vendor = d.getVar("VENDOR")

    sbom = {
        "bomFormat": "CycloneDX",
        "specVersion": "1.6",
        "serialNumber": f"urn:uuid:{sbom_serial_number}",
        "version": 1,
        "metadata": {
            "timestamp": timestamp,
            "tools": [{"name": "yocto"}],
            "component": {
                "name": product_name,
                "version": product_version,
                "type": "operating-system",
                "cpe": 'cpe:2.3:*:{}:{}:{}:*:*:*:*:*:*:*'.format(product_vendor or "*", product_name, product_version),
                "purl": 'pkg:generic/{}{}@{}'.format(f"{product_vendor}/" if product_vendor else '', product_name, product_version),
                "bom-ref": f"{sbom_serial_number}"
            }
        },
        "components": [],
        "vulnerabilities": []
    }

    filesdir = d.getVar("CYCLONEDX_EXPORT_TMP", True)
    files = os.listdir(filesdir)
    image_name = d.getVar("IMAGE_NAME")
    image_link_name = d.getVar("IMAGE_LINK_NAME")
    imgdeploydir = Path(d.getVar("IMGDEPLOYDIR"))
    suffix = ".sbom-cyclonedx.json"

    for filename in files:
        if filename.endswith(".json"):
            filepath = os.path.join(filesdir, filename)
            component = read_json(filepath)
            prop_path = os.path.join(filesdir, "buildinfos", filename)
            prop_buildinfo = None
            if os.path.exists(prop_path):
                prop_buildinfo = read_json(prop_path)

            for comp in component["components"]:
                if prop_buildinfo is not None:
                    for prop in prop_buildinfo["properties"]:
                        comp["properties"].append(prop)

                if not bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_NATIVE')) and not "isNative" in comp["tags"]:
                    sbom["components"].append(comp)

    sbom_export_file=os.path.join(imgdeploydir,image_name+suffix)
    write_json(sbom_export_file, sbom)
    if image_link_name:
        link = imgdeploydir / (image_link_name + suffix)
        if link != sbom_export_file:
            link.symlink_to(os.path.relpath(sbom_export_file, link.parent))

}
addtask do_cyclonedx_image after do_rootfs before do_image
do_cyclonedx_image[nostamp] = "1"
do_rootfs[nostamp] = "1"
do_rootfs[recrdeptask] += "do_cyclonedx_component"
do_rootfs[recideptask] += "do_cyclonedx_component"

def cyclonedx_image_depends(d):
    deps = list()

    if bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_BUILDINFOS')):
        if bb.data.inherits_class('image', d):
            boot_pn = d.getVar('PREFERRED_PROVIDER_virtual/bootloader') or ''
            if boot_pn:
                deps.append('%s:do_cyclonedx_buildinfos' % boot_pn)

            kernel_pn = d.getVar('PREFERRED_PROVIDER_virtual/kernel') or ''
            if kernel_pn:
                deps.append('%s:do_cyclonedx_buildinfos' % kernel_pn)

    return ' '.join(deps)

do_cyclonedx_image[depends] += " ${@cyclonedx_image_depends(d)} "

python do_cyclonedx_buildinfos () {
    cve_products_names = d.getVar("CVE_PRODUCT")
    for product in cve_products_names.split():
        # CVE_PRODUCT in recipes may include vendor information for CPE identifiers. If not,
        # use wildcard for vendor.
        if ":" in product:
            vendor, product = product.split(":", 1)
        else:
            vendor = ""

        pkg = {
            "properties": []
        }
        build_files = do_generate_package_activefiles(product,d)
        if len(build_files) >0:
            prop_tfl = {
                "name" : "build_file_list",
                "value" : "{}".format(build_files)
            }
            pkg["properties"].append(prop_tfl)

        build_config = get_config(product,d)
        if len(build_config) >0:
            prop_bc = {
                "name" : "build_config_list",
                "value" : "{}".format(build_config)
            }
            pkg["properties"].append(prop_bc)

        path = os.path.join(d.getVar("CYCLONEDX_EXPORT_TMP"), "buildinfos")
        if not os.path.exists(path):
            bb.utils.mkdirhier(path)

        sbom_file = os.path.join(path, d.getVar("CYCLONEDX_EXPORT_COMPONENT_FILE"))

        write_json(sbom_file, pkg)
}
do_cyclonedx_buildinfos[nostamp] = "1"

def generate_packages_list(d):
    """
    Get a list of products and generate CPE and PURL identifiers for each of them.
    """
    import uuid

    packages = []

    cve_products_names = d.getVar("CVE_PRODUCT")
    cve_version = d.getVar("CVE_VERSION")
    # keep only the short version which can be matched against vulnerabilities databases
    cve_version = cve_version.split("+git")[0]

    # some packages have alternative names, so we split CVE_PRODUCT
    for product in cve_products_names.split():
        # CVE_PRODUCT in recipes may include vendor information for CPE identifiers. If not,
        # use wildcard for vendor.
        if ":" in product:
            vendor, product = product.split(":", 1)
        else:
            vendor = ""

        pkg = {
            "name": product,
            "version": cve_version,
            "type": "library",
            "description" : '{}'.format(d.getVar("SUMMARY",True)),
            "licenses" : [],
            "supplier" : {
                "name" : '{}'.format(d.getVar('SPDX_SUPPLIER')),
                "url" : '{}'.format(d.getVar('HOMEPAGE', True ))
            },
            "cpe": 'cpe:2.3:*:{}:{}:{}:*:*:*:*:*:*:*'.format(vendor or "*", product, cve_version),
            "purl": 'pkg:generic/{}{}@{}'.format(f"{vendor}/" if vendor else '', product, cve_version),
            "bom-ref": str(uuid.uuid4()),
            "properties": [],
            "tags" : []
        }
        lic = {
            "license" : {
                "name" : '{}'.format(d.getVar("LICENSE",True))
            }
        }
        pkg["licenses"].append(lic)

        if bb.data.inherits_class("native", d) or bb.data.inherits_class("cross", d):
            pkg["tags"].append("isNative")

        for property in d.getVar("CYCLONEDX_EXPORT_PROPERTIES").split(" "):
            if property == "SRC_URI":
                value = list((d.getVar(property) or "").split())
            else:
                value = d.getVar(property)
            if value is not None and len(value) > 0:
                prop = {
                    "name" : property,
                    "value" : "{}".format(value)
                }
                pkg["properties"].append(prop)

        if vendor != "":
            pkg["group"] = vendor
        packages.append(pkg)
    return packages

# only for makefiles
# product is CVE_PRODUCT name
def do_generate_package_activefiles(product,d):
    import os

    sourcetree = list()
    sourcetree.append(d.getVar("B"))
    makefile_targets = list (())
    if product == "linux_kernel":
        makefile_targets = list (("vmlinux", "modules"))
        sourcetree.append(d.getVar("STAGING_KERNEL_DIR"))
    else:
        sourcetree.append(d.getVar("S"))
    sourcetree.append(d.getVar("RECIPE_SYSROOT_NATIVE"))
    sourcetree.append(d.getVar("RECIPE_SYSROOT"))

    makefile = os.path.join(sourcetree[0], "Makefile")
    if os.path.isfile(makefile):
        return  make_dry_run(sourcetree, d, makefile_targets)

    return set()

def make_dry_run(sourcerepo, d, targets : list):
    import re
    import subprocess
    #Witih prefix,  otherwise it takes ages
    path_regex = re.compile('Prerequisite|target \'([^\s]*\w+\.[cSh])')

    arch = d.getVar("ARCH")
    if arch is None:
        arch = d.getVar("TARGET_ARCH")
    makeargs = [ "make", "ARCH="+arch, "-C", sourcerepo[0], "-ndi"]
    makeargs.extend(targets)
    try:
        proc = subprocess.run(makeargs, capture_output=True, encoding='UTF-8')
        if proc.returncode == 0:
            temp = set(path_regex.findall(proc.stdout))
            for repo in sourcerepo:
                real_path = os.path.realpath(repo)
                temp = [y.replace(real_path + "/", "") for y in temp]
            return temp
        else:
            return set()
    except subprocess.CalledProcessError:
        return set()

def get_config(product,d):
    confignodes = list()
    configfile = os.path.join(d.getVar("B"), ".config")
    if os.path.isfile(configfile):
        f = open(configfile,"r")
        for x in f:
            if "CONFIG_" in x:
                confignodes.append(x.strip())
        f.close()
    return confignodes

def read_json(path):
    import json
    from pathlib import Path
    return json.loads(Path(path).read_text())

def write_json(path, content):
    import json
    from pathlib import Path
    Path(path).write_text(
        json.dumps(content, indent=2)
    )

python() {
    if bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_BUILDINFOS')):
        pn = d.getVar('PN')

        kernel_pn = d.getVar('PREFERRED_PROVIDER_virtual/kernel') or ''

        if pn == kernel_pn:
            bb.build.addtask('do_cyclonedx_buildinfos', 'do_rm_work', 'do_compile', d)
            d.appendVarFlag('do_cyclonedx_buildinfos', 'depends', ' %s:do_compile' % pn)

        boot_pn = d.getVar('PREFERRED_PROVIDER_virtual/bootloader') or ''
        if pn == boot_pn:
            bb.build.addtask('do_cyclonedx_buildinfos', 'do_rm_work', 'do_compile', d)
            d.appendVarFlag('do_cyclonedx_buildinfos', 'depends', ' %s:do_compile' % pn)
}
