# Copyright (C) 2015 PHYTEC Messtechnik GmbH,
# Author: Wadim Egorov <w.egorov@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "ViennaCL is a free open-source linear algebra library for\
computations on many-core architectures (GPUs, MIC) and multi-core CPUs.\
The library is written in C++ and supports CUDA, OpenCL, and OpenMP\
(including switches at runtime)."
HOMEPAGE = "http://viennacl.sourceforge.net/"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://LICENSE;md5=02f8300a8eef6ede5cbc35fdec63f2a1"

inherit cmake

PR = "r0"

S = "${WORKDIR}/ViennaCL-1.7.1"

SRC_URI = "http://downloads.sourceforge.net/project/viennacl/1.7.x/ViennaCL-1.7.1.tar.gz"

SRC_URI[md5sum] = "00939858309689d32247d6fe60383b88"
SRC_URI[sha256sum] = "a596b77972ad3d2bab9d4e63200b171cd0e709fb3f0ceabcaf3668c87d3a238b"

DEPENDS += "virtual/opencl"

do_install () {
	install -d ${D}${bindir}
	install -m 755 ${B}/examples/benchmarks/opencl-bench-opencl ${D}${bindir}/
	install -m 755 ${B}/examples/benchmarks/dense_blas-bench-cpu ${D}${bindir}/
	install -m 755 ${B}/examples/benchmarks/dense_blas-bench-opencl ${D}${bindir}/
	install -m 755 ${B}/examples/benchmarks/scheduler-bench-cpu ${D}${bindir}/
}

COMPATIBLE_MACHINE = "(arm)"
