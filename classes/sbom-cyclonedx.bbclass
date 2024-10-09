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

CYCLONEDX_EXPORT_DIR ??= "${DEPLOY_DIR}/sbom-cyclonedx"
CYCLONEDX_EXPORT_SBOM ??= "${CYCLONEDX_EXPORT_DIR}/bom.json"
CYCLONEDX_EXPORT_TMP ??= "${LOG_DIR}/sbom-cyclonedx"
CYCLONEDX_EXPORT_COMPONENT_FILE ??= "${CYCLONEDX_EXPORT_TMP}/${PN}-${PV}.json"
CVE_PRODUCT ??= "${BPN}"
CVE_VERSION ??= "${PV}"

python do_cyclonedx_init() {
    import os.path
    import uuid
    from datetime import datetime, timezone

    timestamp = datetime.now(timezone.utc).isoformat()
    sbom_dir = d.getVar("CYCLONEDX_EXPORT_DIR")
    bb.utils.mkdirhier(sbom_dir)
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
    write_json(d.getVar("CYCLONEDX_EXPORT_SBOM"), sbom_initial)
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
    sbom = read_json(d.getVar("CYCLONEDX_EXPORT_SBOM"))
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
    filesdir = d.getVar("CYCLONEDX_EXPORT_TMP", True)
    files = os.listdir(filesdir)

    sbom_file = d.getVar("CYCLONEDX_EXPORT_SBOM")
    sbom = read_json(sbom_file)
    for filename in files:
        if filename.endswith(".json"):
            filepath = os.path.join(filesdir, filename)
            component = read_json(filepath)
            for comp in component["components"]:
                sbom["components"].append(comp)
    write_json(sbom_file, sbom)
}
addhandler create_sbom_cyclonedx_summary
create_sbom_cyclonedx_summary[eventmask] = "bb.event.BuildCompleted"

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
            "name": d.getVar("BPN"),
            "version": d.getVar("PV"),
            "type": "library",
            "cpe": 'cpe:2.3:*:{}:{}:{}:*:*:*:*:*:*:*'.format(vendor or "*", product, cve_version),
            "purl": 'pkg:generic/{}{}@{}'.format(f"{vendor}/" if vendor else '', product, cve_version),
            "bom-ref": str(uuid.uuid4())
        }

        if vendor != "":
            pkg["group"] = vendor
        packages.append(pkg)
    return packages

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
