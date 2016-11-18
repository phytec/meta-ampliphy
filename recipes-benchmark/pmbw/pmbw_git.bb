SUMMERY = "Parallel Memory Bandwidth Measurement / Benchmark"
DESCRIPTION = "\
The tool pmbw is a set of assembler routines to measure the parallel memory \
(cache and RAM) bandwidth of modern multi-core machines."
HOMEPAGE = "http://panthema.net/2013/pmbw/"
SECTION = "benchmark/tests"
AUTHOR = "Timo Bingmann"
LICENSE = "GPLv3"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

SRC_URI = "git://github.com/bingmann/pmbw;protocol=https"

PV = "0.6.2+git${SRCPV}"
SRCREV = "4a3b37728060a8aba06fc83f157a1965088d79d6"

S = "${WORKDIR}/git"

inherit autotools

PACKAGES =+ "${PN}-stats2gnuplot"

FILES_${PN}-stats2gnuplot = "${bindir}/stats2gnuplot"

RRECOMMENDS_${PN} = "${PN}-stats2gnuplot"
