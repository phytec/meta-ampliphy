DESCRIPTION = "PHYTEC i.MX 95 camera examples"
HOMEPAGE = "http://www.phytec.de"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://COPYING.MIT;md5=16469200a43ccc97395e139bb705a9e2"

SECTION = "multimedia"

PR = "r0"

SRC_URI = "git://github.com/phytec/demo-camera-examples-imx95;protocol=https;branch=main"
SRCREV = "50a6e4a3518d3e206d8446ec6d74760ae6656f8d"

S = "${WORKDIR}/git"

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

	find ${DESTDIR} -type f -iname "*.sh" -exec chmod 0755 {} \;
	find ${DESTDIR} -type f -iname "*.py" -exec chmod 0755 {} \;

	# Create link in home folder for old documentation
	install -d ${D}${ROOT_HOME}
	ln -s ${datadir}/phytec-gstreamer-examples ${D}${ROOT_HOME}/gstreamer-examples
	ln -s ${datadir}/phytec-yavta-examples ${D}${ROOT_HOME}/yavta-examples
}

FILES:${PN} += " \
    ${ROOT_HOME}/ \
    ${datadir}/phytec-gstreamer-examples \
    ${datadir}/phytec-yavta-examples \
"

RDEPENDS:${PN} += " \
    bash \
    media-ctl \
    v4l-utils \
    phycam-setup \
    libcamera \
    libcamera-gst \
    gstreamer1.0 \
    gstreamer1.0-plugins-base \
    gstreamer1.0-plugins-good-multifile \
    gstreamer1.0-plugins-good-video4linux2 \
    gstreamer1.0-plugins-good-matroska \
    gstreamer1.0-plugins-good-jpeg \
    gstreamer1.0-plugins-good-rtp \
    gstreamer1.0-plugins-good-udp \
    gstreamer1.0-plugins-bad-waylandsink \
    gstreamer1.0-plugins-bad-bayer \
    gstreamer1.0-plugins-bad-videoparsersbad \
    gstreamer1.0-plugin-bayer2rgb-neon \
"
