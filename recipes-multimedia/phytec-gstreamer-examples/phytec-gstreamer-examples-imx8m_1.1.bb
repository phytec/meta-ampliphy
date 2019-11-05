DESCRIPTION = "Phytec Gstreamer examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

SECTION = "multimedia"

PR = "r0"

# Archive created via
#   $ unzip gstreamer_examples.zip
#   $ mv gstreamer_examples phytec-gstreamer-examples-imx8m-2.0
#   $ cp phytec-gstreamer-examples-imx8m-1.0/COPYING.MIT  phytec-gstreamer-examples-imx8m-2.0/
#   $ find phytec-gstreamer-examples-imx8m-2.0/ -exec "touch" "{}" ";"
#   $ find phytec-gstreamer-examples-imx8m-2.0/ -name "*.sh" -exec "chmod" "+x" "{}" ";"
#   $ tar --owner=root --group=root -czf phytec-gstreamer-examples-imx8m-2.0.tar.gz \
#        phytec-gstreamer-examples-imx8m-2.0/

SRC_URI = "ftp://ftp.phytec.de/pub/Software/Linux/Applications/${PN}-${PV}.tar.gz"
SRC_URI[md5sum] = "6a95ce2e3f3e86ef7c934470ebc5c76c"
SRC_URI[sha256sum] = "c53658267db3134b27e93e2fe2c435ed688b8c21ac6db56531ef8db588b708e5"

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
	install -d ${D}/home/root
	ln -s ${GSTREAMER_EXAMPLES_DIR} ${D}/home/root/gstreamer_examples
}

FILES_${PN} += " \
    /home/root/ \
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
