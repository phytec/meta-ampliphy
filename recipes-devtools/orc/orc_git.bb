SUMMARY = "Optimised Inner Loop Runtime Compiler"
HOMEPAGE = "http://gstreamer.freedesktop.org/modules/orc.html"
LICENSE = "BSD-2-Clause & BSD-3-Clause"
LIC_FILES_CHKSUM = "file://COPYING;md5=1400bd9d09e8af56b9ec982b3d85797e"

DEFAULT_PREFERENCE = "-1"

SRC_URI = "git://gitlab.freedesktop.org/gstreamer/orc;branch=master"
SRCREV = "b732715f737595884dd54d1f7860982652b2482f"

PV = "0.4.32+git${SRCPV}"

inherit meson pkgconfig

BBCLASSEXTEND = "native nativesdk"

S = "${WORKDIR}/git"

PACKAGES =+ "orc-examples"
PACKAGES_DYNAMIC += "^liborc-.*"
FILES:orc-examples = "${libdir}/orc/*"
FILES:${PN} = "${bindir}/*"

python populate_packages:prepend () {
    libdir = d.expand('${libdir}')
    do_split_packages(d, libdir, r'^lib(.*)\.so\.*', 'lib%s', 'ORC %s library', extra_depends='', allow_links=True)
}

do_compile:prepend:class-native () {
    sed -i -e 's#/tmp#.#g' ${S}/orc/orccodemem.c
