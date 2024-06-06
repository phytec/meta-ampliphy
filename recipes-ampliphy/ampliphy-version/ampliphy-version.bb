LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "${DISTRO_VERSION}"
PR = "r12"
PE = "2"

SRC_URI = "file://lsb_release"

S = "${WORKDIR}/sources"
UNPACKDIR = "${S}"

PACKAGES = "${PN}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit metadata_scm

def _revision_str(revision):
    return f"{revision[2]}:{revision[3]}"

def get_layers(d):
    revisions = oe.buildcfg.get_layer_revisions(d)
    layers_branch_rev = []

    for index , revision in enumerate(revisions):
        current = _revision_str(revision)
        if index == 0 or current != _revision_str(revisions[index - 1]):
            # draw full line
            layers_branch_rev .insert(0, f"{revision[1]:17} = {current}")  # prepend to list
        else:
            # same revision only add branch name
            layers_branch_rev .insert(0, revision[1])  # prepend to list

    layertext = "Configured Openembedded layers:\n%s\n" % '\n'.join(layers_branch_rev)
    return layertext

do_install() {
	install -d ${D}${sysconfdir}
	echo "ampliPHY ${DISTRO_VERSION} (${VERSION_CODENAME})" > ${D}${sysconfdir}/ampliphy-version
	echo "Built from branch: ${METADATA_BRANCH}" >> ${D}${sysconfdir}/ampliphy-version
	echo "Revision: ${METADATA_REVISION}" >> ${D}${sysconfdir}/ampliphy-version
	echo "Target system: ${TARGET_SYS}" >> ${D}${sysconfdir}/ampliphy-version

	echo "${@get_layers(d)}" > ${D}${sysconfdir}/ampliphy-build-info

	echo "VERSION=\"${DISTRO_VERSION}\"" > ${D}${sysconfdir}/os-release
	echo "NAME=\"ampliPHY\"" >> ${D}${sysconfdir}/os-release
	echo "ID=\"ampliphy\"" >> ${D}${sysconfdir}/os-release
	echo "PRETTY_NAME=\"The ampliPHY Distribution ${DISTRO_VERSION}\"" >> ${D}${sysconfdir}/os-release
	echo "ANSI_COLOR=\"1;35\"" >> ${D}${sysconfdir}/os-release
	echo "HOME_URL=\"http://www.phytec.de\"" >> ${D}${sysconfdir}/os-release

	install -d ${D}${bindir}
	install -m 0755 ${UNPACKDIR}/lsb_release ${D}${bindir}/
}
RPROVIDES:${PN} = "os-release"
RREPLACES:${PN} = "os-release"
RCONFLICTS:${PN} = "os-release"

