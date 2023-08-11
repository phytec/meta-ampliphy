DESCRIPTION = "Virtualization tools used on Phytec boards"
LICENSE = "MIT"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

RDEPENDS:${PN} += " \
    podman \
    podman-compose \
"
