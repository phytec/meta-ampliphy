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
CYCLONEDX_EXPORT_COMPONENT_BASE ??= "${CYCLONEDX_EXPORT_TMP}/base-bom.json"
CYCLONEDX_EXPORT_COMPONENT_FILE ??= "${CYCLONEDX_EXPORT_TMP}/${PN}-${PV}.json"
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"
# Add variable values to the property array of CycloneDX SBOM
CYCLONEDX_EXPORT_PROPERTIES ??= "SRC_URI SRCREV"
# Add build artefacts for better analysis of the component
CYCLONEDX_EXPORT_BUILDFILES ??= "linux_kernel barebox u-boot busybox"

SPDX_ORG ??= "OpenEmbedded ()"
SPDX_SUPPLIER ??= "Organization: ${SPDX_ORG}"

python do_cyclonedx_init() {
    import os.path
    import uuid
    from datetime import datetime, timezone

    timestamp = datetime.now(timezone.utc).isoformat()
    if not os.path.exists(d.getVar("CYCLONEDX_EXPORT_TMP")):
        bb.utils.mkdirhier(d.getVar("CYCLONEDX_EXPORT_TMP"))

    # Generate unique serial numbers for sbom
    sbom_serial_number = str(uuid.uuid4())

    product_name = d.getVar("DISTRO")
    product_version = d.getVar("DISTRO_VERSION")
    product_vendor = d.getVar("VENDOR")

    sbom_initial = {
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
    write_json(d.getVar("CYCLONEDX_EXPORT_COMPONENT_BASE"), sbom_initial)
}
addhandler do_cyclonedx_init
do_cyclonedx_init[eventmask] = "bb.event.BuildStarted"

python do_create_sbom_cyclonedx () {
    import os
    for ignored_suffix in (d.getVar("SPECIAL_PKGSUFFIX") or "").split():
        if d.getVar("PN").endswith(ignored_suffix):
            return

    # load the bom
    sbom_file = d.getVar("CYCLONEDX_EXPORT_COMPONENT_FILE")
    sbom = read_json(d.getVar("CYCLONEDX_EXPORT_COMPONENT_BASE"))
    for pkg in generate_packages_list(d):
        if not next((c for c in sbom["components"] if c["cpe"] == pkg["cpe"]), None):
            sbom["components"].append(pkg)

    write_json(sbom_file, sbom)
}
addtask create_sbom_cyclonedx after do_compile before do_install
create_sbom_cyclonedx[nostamp] = "1"
create_sbom_cyclonedx[depends] += "python3-native:do_populate_sysroot"
create_sbom_cyclonedx[depends] += "python3-packaging-native:do_populate_sysroot"

python create_sbom_cyclonedx_summary() {
    import json
    import os
    from pathlib import Path

    filesdir = d.getVar("CYCLONEDX_EXPORT_TMP", True)
    files = os.listdir(filesdir)
    image_name = d.getVar("IMAGE_NAME")
    image_link_name = d.getVar("IMAGE_LINK_NAME")
    imgdeploydir = Path(d.getVar("IMGDEPLOYDIR"))
    suffix = ".sbom-cyclonedx.json"

    sbom_file = d.getVar("CYCLONEDX_EXPORT_COMPONENT_BASE")
    sbom = read_json(sbom_file)
    for filename in files:
        if filename.endswith(".json"):
            filepath = os.path.join(filesdir, filename)
            component = read_json(filepath)
            for comp in component["components"]:
                sbom["components"].append(comp)
    sbom_export_file=os.path.join(imgdeploydir,image_name+suffix)
    write_json(sbom_export_file, sbom)
    if image_link_name:
        link = imgdeploydir / (image_link_name + suffix)
        if link != sbom_export_file:
            link.symlink_to(os.path.relpath(sbom_export_file, link.parent))

}

ROOTFS_POSTUNINSTALL_COMMAND =+ "create_sbom_cyclonedx_summary"

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
            "properties": []
        }
        lic = {
            "license" : {
                "name" : '{}'.format(d.getVar("LICENSE",True))
            }
        }
        pkg["licenses"].append(lic)

        for property in d.getVar("CYCLONEDX_EXPORT_PROPERTIES").split(" "):
            value = d.getVar(property)
            if value is not None and len(value) > 0:
                prop = {
                    "name" : property,
                    "value" : "{}".format(value)
                }
                pkg["properties"].append(prop)

        if product in d.getVar("CYCLONEDX_EXPORT_BUILDFILES"):
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

python () {
    is_native_class = d.getVar('CLASSOVERRIDE') in ("class-native", "class-nativesdk")
    is_native = d.getVar('OVERRIDE') in ("native", "nativesdk")
    if is_native_class or is_native:
        bb.build.deltask('create_sbom_cyclonedx', d)
}
