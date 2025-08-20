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

CYCLONEDX_EXPORT_TMP ??= "${WORKDIR}/sbom-cyclonedx"

DEPLOY_DIR_CYCLONEDX_BASE ??= "${DEPLOY_DIR}/sbom-cyclonedx/${MACHINE}"
DEPLOY_DIR_CYCLONEDX ??= "${DEPLOY_DIR_CYCLONEDX_BASE}/${BB_CURRENT_MC}"
CYCLONEDX_EXPORT_COMPONENT_FILE ??= "${PN}-${PV}.json"
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"
# Add variable values to the property array of CycloneDX SBOM
CYCLONEDX_EXPORT_PROPERTIES ??= "SRC_URI SRCREV BB_CURRENT_MC"

CYCLONEDX_WITH_BUILDINFOS ??="0"
CYCLONEDX_WITH_NATIVE ??="0"

SPDX_ORG ??= "OpenEmbedded ()"
SPDX_SUPPLIER ??= "Organization: ${SPDX_ORG}"

python do_cyclonedx_component() {
    sbom = {
        "components": []
    }
    for comp in generate_packages_list(d):
        if bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_BUILDINFOS')):
            pn = d.getVar('PN')

            kernel_pn = d.getVar('PREFERRED_PROVIDER_virtual/kernel') or ''
            boot_pn = d.getVar('PREFERRED_PROVIDER_virtual/bootloader') or ''
            if pn == boot_pn or pn == kernel_pn:
                prop_buildinfo = do_cyclonedx_buildinfos(d)
                if prop_buildinfo is not None:
                    for prop in prop_buildinfo["properties"]:
                        comp["properties"].append(prop)
        sbom["components"].append(comp)

    path = d.getVar("CYCLONEDX_EXPORT_TMP")
    if not os.path.exists(path):
        bb.utils.mkdirhier(path)
    sbom_file = os.path.join(path, d.getVar("CYCLONEDX_EXPORT_COMPONENT_FILE"))

    write_json(sbom_file, sbom)
}
addtask do_cyclonedx_component after do_package do_packagedata do_unpack before do_populate_sdk do_build do_rm_work
do_cyclonedx_component[rdeptask] += "do_unpack do_packagedata"

SSTATETASKS += "do_cyclonedx_component"
do_cyclonedx_component[sstate-inputdirs] = "${CYCLONEDX_EXPORT_TMP}"
do_cyclonedx_component[sstate-outputdirs] = "${DEPLOY_DIR_CYCLONEDX}"
do_cyclonedx_component[depends] += "${PATCHDEPENDENCY}"

python do_cyclonedx_component_setscene () {
    sstate_setscene(d)
}
addtask do_cyclonedx_component_setscene

do_cyclonedx_component[cleandirs] = "${CYCLONEDX_EXPORT_TMP}"
do_cyclonedx_component[stamp-extra-info] = "${MACHINE_ARCH}"

python do_cyclonedx_image() {
    import os.path
    import uuid
    from datetime import datetime, timezone
    import os
    from pathlib import Path
    from oe.rootfs import image_list_installed_packages

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
            "tools": {
                 "components" : [ {"name": "Yocto CycloneDX SBOM Creator", "version" : "1.1","type": "application"}]
            },
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

    image_name = d.getVar("IMAGE_NAME")
    image_link_name = d.getVar("IMAGE_LINK_NAME")
    imgdeploydir = Path(d.getVar("IMGDEPLOYDIR"))
    suffix = ".sbom-cyclonedx.json"

    deploy_base_dir = d.getVar("DEPLOY_DIR_CYCLONEDX_BASE", True)
    for entry in os.listdir(deploy_base_dir):
        filesdir = os.path.join(deploy_base_dir, entry)
        if os.path.isdir(filesdir):
            files = os.listdir(filesdir)
            for filename in files:
                if filename.endswith(".json"):
                    filepath = os.path.join(filesdir, filename)
                    component = read_json(filepath)
                    for comp in component["components"]:
                        if not bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_NATIVE')) and not "isNative" in comp["tags"]:
                            add_comp = True
                            for sbom_comp in sbom["components"]:
                                if comp["cpe"] == sbom_comp["cpe"]:
                                    values_changed = diff_json(comp, sbom_comp, [])
                                    # if identical or only bom-ref is different, then it is the same component
                                    if len(values_changed) == 0 \
                                        or (len(values_changed) == 1 and ".bom-ref" in values_changed):
                                        add_comp = False
                                        break;
                            if add_comp:
                                sbom["components"].append(comp)

    packages = sorted(image_list_installed_packages(d).keys())
    for sbom_comp in sbom["components"]:
        if sbom_comp["name"] in packages and not "isNative" in sbom_comp["tags"]:
            sbom_comp["tags"].append("isInRootFS")

    sbom_export_file=os.path.join(imgdeploydir,image_name+suffix)
    write_json(sbom_export_file, sbom)
    if image_link_name:
        link = imgdeploydir / (image_link_name + suffix)
        if link != sbom_export_file:
            link.symlink_to(os.path.relpath(sbom_export_file, link.parent))

}
do_rootfs[recrdeptask] += "do_cyclonedx_component"

ROOTFS_POSTUNINSTALL_COMMAND =+ "do_cyclonedx_image"
do_rootfs[depends] += "${DEP_BOOTLOADER}:do_deploy"

def do_cyclonedx_buildinfos (d):
    cve_products_names = d.getVar("CVE_PRODUCT")
    for product in cve_products_names.split():
        # CVE_PRODUCT in recipes may include vendor information for CPE identifiers. If not,
        # use wildcard for vendor.
        if ":" in product:
            vendor, product = product.split(":", 1)
        else:
            vendor = ""

        builddir = list()
        builddir.append(d.getVar("B"))
        if product == "u-boot":
            ubootmachine = d.getVar("UBOOT_MACHINE").lstrip().split(" ")
            for machine in ubootmachine:
                builddir.append(os.path.join(d.getVar("B"), machine))

        build_files = do_generate_package_activefiles(product,builddir,d)
        build_config = get_config(product,builddir,d)
        if len(build_files) >0 and len(build_config) >0:
            pkg = {
                "properties": [
                    {
                        "name" : "build_file_list",
                        "value" : "{}".format(build_files)
                    },
                    {
                        "name" : "build_config_list",
                        "value" : "{}".format(build_config)
                    }
                ]
            }
            return pkg
    return None

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
def do_generate_package_activefiles(product,builddir,d):
    import os
    import re
    import subprocess

    path_regex = re.compile('Prerequisite|target \'([^\s]*\w+\.[cSh])')

    sourcetree = builddir
    makefile_targets = list (())
    if product == "linux_kernel":
        makefile_targets = list (("vmlinux", "modules"))
        sourcetree.append(d.getVar("STAGING_KERNEL_DIR"))
    else:
        sourcetree.append(d.getVar("S"))
    sourcetree.append(d.getVar("RECIPE_SYSROOT_NATIVE"))
    sourcetree.append(d.getVar("RECIPE_SYSROOT"))

    make_parameter=""
    if product == "u-boot":
        make_parameter="CROSS_COMPILE="+d.getVar("TARGET_PREFIX")
    else:
        arch = d.getVar("ARCH")
        if arch is None:
            arch = d.getVar("TARGET_ARCH")
        make_parameter="ARCH="+arch

    for dir in builddir:
        makefile = os.path.join(dir, "Makefile")

        if os.path.isfile(makefile):
            makeargs = [ "make", make_parameter, "-C", dir, "-ndi"]
            makeargs.extend(makefile_targets)
            try:
                proc = subprocess.run(makeargs, capture_output=True, encoding='UTF-8')
                if proc.returncode == 0:
                    temp = set(path_regex.findall(proc.stdout))
                    for repo in sourcetree:
                        real_path = os.path.realpath(repo)
                        temp = [y.replace(real_path + "/", "") for y in temp]
                    if len(temp) >0:
                        return temp
            except subprocess.CalledProcessError:
                bb.warn("cyclondx dry_run: ProcessError")
    return set()

def get_config(product,builddir,d):
    for dir in builddir:
        configfile = os.path.join(dir, ".config")
        if os.path.isfile(configfile):
            confignodes = list()
            f = open(configfile,"r")
            for x in f:
                if "CONFIG_" in x:
                    confignodes.append(x.strip())
            f.close()
            if len(confignodes) > 0:
                return confignodes
    return list()

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

def diff_json(obj1, obj2, values_changed, path=""):
    if type(obj1) != type(obj2):
        values_changed.append(path)
    else:
        if isinstance(obj1, dict):
            for key in obj1:
                if key not in obj2:
                    values_changed.append(path)
                values_changed = diff_json(obj1[key], obj2[key], values_changed, f"{path}.{key}")
            for key in obj2:
                if key not in obj1:
                    values_changed.append(path)
        elif isinstance(obj1, list):
            if len(obj1) != len(obj2):
                values_changed.append(path)
            for idx, (item1, item2) in enumerate(zip(obj1, obj2)):
                values_changed = diff_json(item1, item2, values_changed, f"{path}[{idx}]")
        else:
            if obj1 != obj2:
                values_changed.append(path)
    return values_changed

python() {
    if bb.utils.to_boolean(d.getVar('CYCLONEDX_WITH_BUILDINFOS')):
        pn = d.getVar('PN')

        kernel_pn = d.getVar('PREFERRED_PROVIDER_virtual/kernel') or ''

        if pn == kernel_pn:
            d.appendVarFlag('do_cyclonedx_component', 'depends', ' %s:do_compile' % pn)

        boot_pn = d.getVar('PREFERRED_PROVIDER_virtual/bootloader') or ''
        if pn == boot_pn:
            d.appendVarFlag('do_cyclonedx_component', 'depends', ' %s:do_compile' % pn)
}
