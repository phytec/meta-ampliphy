DESCRIPTION = "Task to add Qt embedded related packages"
LICENSE = "MIT"
PR = "r7"

PACKAGE_ARCH = "${MACHINE_ARCH}"

inherit packagegroup

QT4_DEMOS = "\
    qt4-embedded-examples \
    qt4-embedded-demos \
"

RDEPENDS_${PN} = "\
    packagegroup-ti-qt4e \
    ${QT4_DEMOS} \
"
