DESCRIPTION = "PHYTEC camera examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=16469200a43ccc97395e139bb705a9e2"

SECTION = "multimedia"

PR = "r0"

# Archive created via
#   $ mkdir phytec-camera-examples
#   $ unzip gstreamer-examples.zip
#   $ mv gstreamer-examples phytec-camera-examples/phytec-gstreamer-examples
#   $ mv v4l2_c-examples/ phytec-camera-examples/phytec-v4l2_c-examples
#   $ mv opencv-examples/ phytec-camera-examples/phytec-opencv-examples
#   $ mv phytec-camera-examples/phytec-gstreamer-examples/COPYING.MIT \
#   $ phytec-camera-examples/
#   $ mv phytec-camera-examples phytec-camera-examples-imx8mp-2.1
#   $ find phytec-camera-examples-imx8mp-2.1/ -exec "touch" "{}" ";"
#   $ find phytec-camera-examples-imx8mp-2.1/ -name "*.sh" -or -iname "*.py" -exec "chmod" "+x" "{}" ";"
#   $ tar -czf phytec-camera-examples-imx8mp-2.1.tar.gz \
#     phytec-camera-examples-imx8mp-2.1/

SRC_URI = "https://download.phytec.de/Software/Linux/Applications/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "d02158fa65a6477f27bb3b4b50267472"
SRC_URI[sha256sum] = "61508c6754e25146b0477cb2ba4fbc92a29cb52d11af26b17443016002fb8f8d"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
	DESTDIR="${D}${datadir}"

	for dir in `find -type d`; do
		if [ ${dir} != "./patches" ]; then
			install -d ${DESTDIR}/${dir}
		fi
	done

	for file in `find ./*/ -type f`; do
		install -m 0644 ${file} ${DESTDIR}/${file}
	done

	find ${DESTDIR} -type f -iname "*.sh" -exec chmod 0755 {} \;
	find ${DESTDIR} -type f -iname "*.py" -exec chmod 0755 {} \;

	# Create link in home folder for old documentation
	install -d ${D}${ROOT_HOME}
	ln -s ${datadir}/phytec-gstreamer-examples ${D}${ROOT_HOME}/gstreamer-examples
	ln -s ${datadir}/phytec-v4l2_c-examples ${D}${ROOT_HOME}/v4l2_c-examples
	ln -s ${datadir}/phytec-opencv-examples ${D}${ROOT_HOME}/opencv-examples
}

FILES:${PN} += " \
    ${ROOT_HOME}/ \
    ${datadir}/phytec-gstreamer-examples \
    ${datadir}/phytec-v4l2_c-examples \
    ${datadir}/phytec-opencv-examples \
"

RDEPENDS:${PN} += " \
    bash \
    python3 \
    media-ctl \
    v4l-utils \
    gstreamer1.0 \
    gstreamer1.0-plugins-good-multifile \
    gstreamer1.0-plugins-good-video4linux2 \
    gstreamer1.0-plugins-bad-fbdevsink \
    gstreamer1.0-plugins-bad-bayer \
    gstreamer1.0-plugins-good-jpeg \
    gstreamer1.0-plugin-bayer2rgb-neon \
    gstreamer1.0-plugin-pseudocolor \
"