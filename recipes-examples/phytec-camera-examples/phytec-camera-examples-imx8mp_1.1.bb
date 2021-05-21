DESCRIPTION = "PHYTEC camera examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=16469200a43ccc97395e139bb705a9e2"

SECTION = "multimedia"

PR = "r0"

# Archive created via
#   $ mkdir phytec-camera-examples
#   $ unzip gstreamer-examples_V1.1.zip
#   $ mv gstreamer-examples_V1.1 phytec-camera-examples/phytec-gstreamer-examples
#   $ mv v4l2_c-examples_V1.1/ phytec-camera-examples/phytec-v4l2_c-examples
#   $ mv opencv-examples_V1.1/ phytec-camera-examples/phytec-opencv-examples
#   $ mv phytec-camera-examples/phytec-gstreamer-examples/COPYING.MIT \
#   $ phytec-camera-examples/
#   $ mv phytec-camera-examples phytec-camera-examples-imx8mp-1.1
#   $ find phytec-camera-examples-imx8mp-1.1/ -exec "touch" "{}" ";"
#   $ find phytec-camera-examples-imx8mp-1.1/ -name "*.sh" -or -iname "*.py" -exec "chmod" "+x" "{}" ";"
#   $ tar -czf phytec-camera-examples-imx8mp-1.1.tar.gz \
#     phytec-camera-examples-imx8mp-1.1/

SRC_URI = "https://download.phytec.de/Software/Linux/Applications/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "a0b0666613d52ba7180c315ac3002893"
SRC_URI[sha256sum] = "2e526b292be339c24d8455561c9b45147ebb1ab0c06d37100b390acc63aae278"

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

FILES_${PN} += " \
    ${ROOT_HOME}/ \
    ${datadir}/phytec-gstreamer-examples \
    ${datadir}/phytec-v4l2_c-examples \
    ${datadir}/phytec-opencv-examples \
"

RDEPENDS_${PN} += " \
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
