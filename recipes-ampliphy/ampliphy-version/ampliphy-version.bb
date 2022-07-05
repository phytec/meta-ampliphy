LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COMMON_LICENSE_DIR}/MIT;md5=0835ade698e0bcf8506ecda2f7b4f302"

PV = "${DISTRO_VERSION}"
PR = "r12"
PE = "2"

SRC_URI = "file://lsb_release"

PACKAGES = "${PN}"
PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit metadata_scm

def get_layers(d):
    revisions = oe.buildcfg.get_layer_revisions(d)
    layers_branch_rev = ["%-17s = \"%s:%s\"" % (r[1], r[2], r[3]) \
        for r in revisions]
    i = len(layers_branch_rev)-1
    p1 = layers_branch_rev[i].find("=")
    s1= layers_branch_rev[i][p1:]
    while i > 0:
        p2 = layers_branch_rev[i-1].find("=")
        s2= layers_branch_rev[i-1][p2:]
        if s1 == s2:
            layers_branch_rev[i-1] = layers_branch_rev[i-1][0:p2]
            i -= 1
        else:
            i -= 1
            p1 = layers_branch_rev[i].find("=")
            s1= layers_branch_rev[i][p1:]

    layertext = "Configured Openembedded layers:\n%s\n" % '\n'.join(layers_branch_rev)
    layertext = layertext.replace('<','')
    layertext = layertext.replace('>','')
    return layertext

do_install() {
	install -d ${D}${sysconfdir}
	echo "ampliPHY ${DISTRO_VERSION} (${DISTRO_CODENAME})" > ${D}${sysconfdir}/ampliphy-version
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
	install -m 0755 ${WORKDIR}/lsb_release ${D}${bindir}/
}
RPROVIDES:${PN} = "os-release"
RREPLACES:${PN} = "os-release"
RCONFLICTS:${PN} = "os-release"

