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
#   $ mv phytec-camera-examples phytec-camera-examples-imx8mp-3.2
#   $ find phytec-camera-examples-imx8mp-3.2/ -exec "touch" "{}" ";"
#   $ find phytec-camera-examples-imx8mp-3.2/ \( -name "*.sh" -or -iname "*.py" \) -exec "chmod" "+x" "{}" ";"
#   $ tar -czf phytec-camera-examples-imx8mp-3.2.tar.gz \
#     phytec-camera-examples-imx8mp-3.2/

SRC_URI = "https://download.phytec.de/Software/Linux/Applications/${BPN}-${PV}.tar.gz"
SRC_URI[md5sum] = "0a00ac7426e5a8d7277e8ac45ff01994"
SRC_URI[sha256sum] = "abf6fc023f7798026b980a19ffcc7bf34b7c3160bb97c865046ca7dc3a0ad5ff"

do_configure[noexec] = "1"
do_compile[noexec] = "1"

do_install() {
	DESTDIR="${D}${datadir}"

	for file in `find ./phytec-gstreamer-examples/ -type f`; do
		install -m 0644 -D ${file} ${DESTDIR}/${file}
	done

	for file in `find ./phytec-yavta-examples/ -type f`; do
		install -m 0644 -D ${file} ${DESTDIR}/${file}
	done

	for file in `find ./phytec-opencv-examples/ -type f`; do
		install -m 0644 -D ${file} ${DESTDIR}/${file}
	done

	find ${DESTDIR} -type f -iname "*.sh" -exec chmod 0755 {} \;
	find ${DESTDIR} -type f -iname "*.py" -exec chmod 0755 {} \;

	# Create link in home folder for old documentation
	install -d ${D}${ROOT_HOME}
	ln -s ${datadir}/phytec-gstreamer-examples ${D}${ROOT_HOME}/gstreamer-examples
	ln -s ${datadir}/phytec-yavta-examples ${D}${ROOT_HOME}/yavta-examples
	ln -s ${datadir}/phytec-opencv-examples ${D}${ROOT_HOME}/opencv-examples
}

FILES:${PN} += " \
    ${ROOT_HOME}/ \
    ${datadir}/phytec-gstreamer-examples \
    ${datadir}/phytec-yavta-examples \
    ${datadir}/phytec-opencv-examples \
"

RDEPENDS:${PN} += " \
    bash \
    python3-core \
    media-ctl \
    v4l-utils \
    phycam-setup \
    gstreamer1.0 \
    gstreamer1.0-plugins-good-multifile \
    gstreamer1.0-plugins-good-video4linux2 \
    gstreamer1.0-plugins-bad-waylandsink \
    gstreamer1.0-plugins-bad-bayer \
    gstreamer1.0-plugins-good-jpeg \
    gstreamer1.0-plugin-bayer2rgb-neon \
"
