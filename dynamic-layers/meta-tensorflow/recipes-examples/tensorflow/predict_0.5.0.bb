DESCRIPTION = "waits for images on a tcp port, rescales it with opencv, \
runs through a saved model in tensorflow and outputs the result using flask."
HOMEPAGE = "https://www.phytec.de"
LICENSE = "Apache-2.0"
LIC_FILES_CHKSUM = "file://../../LICENSE;md5=2ee41112a44fe7014dce33e26468ba93"

SRC_URI = "git://git.phytec.de/aidemo-customvision"
SRCREV = "2c892f400345872b20ae189ffe6b82250c191151"
S = "${WORKDIR}/git/modules/model"

inherit allarch

do_configure[noexec] = "1"
do_compile[noexec] = "1"

RDEPENDS_${PN} = "tensorflow opencv python3-pillow python3-flask"

PREFIX = "/"

do_install () {
    mkdir -p ${D}${PREFIX}
    cp -R --no-dereference --preserve=mode,links -v ${S}/* ${D}${PREFIX}
}

FILES_${PN} = "${PREFIX}"
INSANE_SKIP_${PN} = "file-rdeps"
