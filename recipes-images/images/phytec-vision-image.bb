require recipes-images/images/phytec-headless-image.bb

SUMMARY =  "This image is designed to show development of camera and \
            imaging applications with openCV."

IMAGE_FEATURES += "splash ssh-server-openssh hwcodecs"
IMAGE_FEATURES += "\
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston', bb.utils.contains('DISTRO_FEATURES', 'x11', 'x11-base', '', d), d)}\
"

LICENSE = "MIT"

IMAGE_INSTALL += "\
    packagegroup-base \
    \
    packagegroup-gstreamer \
    packagegroup-camera \
    \
    opencv \
    opencv-samples \
    opencv-apps \
    gstreamer1.0-plugins-bad-opencv \
    python-phycam-margin-analysis \
    \
    ${@bb.utils.contains('DISTRO_FEATURES', 'wayland', 'weston weston-init', '', d)} \
    ${@bb.utils.contains('DISTRO_FEATURES', 'x11 wayland', 'weston-xwayland', '', d)} \
"

IMAGE_INSTALL:append:mx6-nxp-bsp = "\
    phytec-camera-examples-imx6 \
"

IMAGE_INSTALL:append:mx6ul-nxp-bsp = "\
    phytec-camera-examples-imx6ul \
"

IMAGE_INSTALL:append:mx8mm-nxp-bsp = "\
    phytec-camera-examples-imx8mm \
"

IMAGE_INSTALL:append:mx8mp-nxp-bsp = "\
    phytec-camera-examples-imx8mp \
    isp-imx-phycam \
"
