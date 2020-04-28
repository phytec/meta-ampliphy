# Copyright (C) 2019 Stefan Riedmüller <s.riedmueller@phytec.de>
# Released under the MIT license (see COPYING.MIT for the terms)

DESCRIPTION = "Phytec Gstreamer examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SECTION = "multimedia"

PR = "r0"

# Archive created via
#   $ unzip gstreamer_examples.zip
#   $ mv gstreamer_examples phytec-gstreamer-examples-imx6ul-2.0
#   $ rm phytec-gstreamer-examples-imx6ul-2.0/tools/i2c
#   $ cp phytec-gstreamer-examples-imx6ul-1.0/COPYING.MIT  phytec-gstreamer-examples-imx6ul-2.0/
#   $ find phytec-gstreamer-examples-imx6ul-2.0/ -exec "touch" "{}" ";"
#   $ find phytec-gstreamer-examples-imx6ul-2.0/ -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-gstreamer-examples-imx6ul-2.0.tar.gz \
#        phytec-gstreamer-examples-imx6ul-2.0/

SRC_URI = "ftp://ftp.phytec.de/pub/Software/Linux/Applications/${PN}-${PV}.tar.gz"
SRC_URI[md5sum] = "d9d40b704cf119923baa03b17f15f2fa"
SRC_URI[sha256sum] = "60c17b3ecfa8446b123da24d82f2cbc17b85cf77b221164570b9214b4fc693f3"

GSTREAMER_EXAMPLES_DIR = "${datadir}/phytec-gstreamer-examples"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
	DESTDIR="${D}${GSTREAMER_EXAMPLES_DIR}"

	for directory in `find -type d`; do
		if [ ${directory} != "./patches" ]; then
			install -d ${DESTDIR}/${directory}
		fi
	done

	for text in `find -name '*.txt'`; do
		install -m 0644 ${text} ${DESTDIR}/${text}
	done

	for scripts in `find -name '*.sh'`; do
		install -m 0755 ${scripts} ${DESTDIR}/${scripts}
	done

	# Create link in home folder for old documentation
	install -d ${D}${ROOT_HOME}
	ln -s ${GSTREAMER_EXAMPLES_DIR} ${D}${ROOT_HOME}/gstreamer_examples
}

FILES_${PN} += " \
    ${ROOT_HOME}/ \
    ${GSTREAMER_EXAMPLES_DIR} \
"

RDEPENDS_${PN} += " \
	bash \
	gst-plugin-i2c \
	media-ctl \
	v4l-utils \
	gstreamer1.0 \
	gstreamer1.0-plugins-good-multifile \
	gstreamer1.0-plugins-good-video4linux2 \
	gstreamer1.0-plugins-bad-fbdevsink \
	gstreamer1.0-plugins-bad-bayer \
	gstreamer1.0-plugins-good-jpeg \
	gstreamer1.0-plugin-bayer2rgb-neon \
"
